import { createHash, randomBytes, randomInt, randomUUID, timingSafeEqual } from "node:crypto";
import argon2 from "argon2";
import type { PrismaClient } from "@prisma/client";
import type { FastifyInstance, FastifyRequest } from "fastify";
import { z } from "zod";
import type { ServerConfig } from "./config.js";
import type { AccountEmail } from "./email.js";

const emailSchema = z.string().trim().email().max(254).transform((value) => value.toLowerCase());
const passwordSchema = z.string().min(10).max(128);
const usernameSchema = z.string().trim().min(3).max(20).regex(/^[A-Za-z0-9_]+$/);
const displayNameSchema = z.string().trim().min(1).max(24);
const codeSchema = z.string().regex(/^\d{6}$/);
const registerSchema = z.object({ inviteCode: z.string().min(8).max(128).optional(), email: emailSchema, password: passwordSchema, username: usernameSchema, displayName: displayNameSchema });
const verifySchema = z.object({ email: emailSchema, code: codeSchema });
const loginSchema = z.object({ email: emailSchema, password: z.string().min(1).max(128) });
const refreshSchema = z.object({ refreshToken: z.string().min(20).max(300) });
const forgotSchema = z.object({ email: emailSchema });
const resetSchema = z.object({ email: emailSchema, code: codeSchema, password: passwordSchema });
const profileSchema = z.object({ displayName: displayNameSchema });
const OWNER_INVITE_LABEL = "owner bootstrap";

function hash(value: string): string { return createHash("sha256").update(value).digest("hex"); }
function code(): string { return randomInt(0, 1_000_000).toString().padStart(6, "0"); }
function expiresIn(minutes: number): Date { return new Date(Date.now() + minutes * 60_000); }
function safeHashEquals(a: string, b: string): boolean {
  const left = Buffer.from(a);
  const right = Buffer.from(b);
  return left.length === right.length && timingSafeEqual(left, right);
}

async function issueSession(app: FastifyInstance, db: PrismaClient, config: ServerConfig, accountId: string, familyId: string = randomUUID()) {
  const id = randomUUID();
  const raw = `${id}.${randomBytes(32).toString("base64url")}`;
  await db.authSession.create({ data: { id, accountId, familyId, refreshTokenHash: hash(raw), expiresAt: new Date(Date.now() + config.REFRESH_TOKEN_DAYS * 86_400_000) } });
  return { accessToken: app.jwt.sign({ sub: accountId }, { expiresIn: `${config.ACCESS_TOKEN_MINUTES}m` }), refreshToken: raw, expiresInSeconds: config.ACCESS_TOKEN_MINUTES * 60 };
}

async function accountId(request: FastifyRequest): Promise<string> {
  await request.jwtVerify();
  const user = request.user as { sub?: unknown };
  const subject = user.sub;
  if (typeof subject !== "string") throw new Error("Invalid access token");
  return subject;
}

export function registerAuthRoutes(app: FastifyInstance, db: PrismaClient, config: ServerConfig, emailer: AccountEmail): void {
  app.post("/v1/auth/register", { config: { rateLimit: { max: 5, timeWindow: "15 minutes" } } }, async (request, reply) => {
    const input = registerSchema.parse(request.body);
    if (config.REGISTRATION_MODE === "closed") return reply.code(403).send({ code: "REGISTRATION_CLOSED" });
    const normalizedUsername = input.username.toLowerCase();
    const inviteHash = input.inviteCode ? hash(input.inviteCode.trim()) : "";
    const verificationCode = code();
    const passwordHash = await argon2.hash(input.password);
    try {
      const account = await db.$transaction(async (tx) => {
        let invitation: { id: string; label: string | null } | null = null;
        if (config.REGISTRATION_MODE === "invite") {
          invitation = await tx.invitation.findFirst({
            where: { codeHash: inviteHash, usedAt: null, expiresAt: { gt: new Date() } },
            select: { id: true, label: true },
          });
          if (!invitation) throw new Error("INVALID_INVITE");
        }
        const ownerInvite = invitation?.label === OWNER_INVITE_LABEL;
        if ((ownerInvite && normalizedUsername !== "glitch") || (!ownerInvite && normalizedUsername === "glitch")) {
          throw new Error("USERNAME_UNAVAILABLE");
        }
        const created = await tx.account.create({ data: {
          email: input.email,
          passwordHash,
          profiles: { create: { username: input.username, normalizedUsername, displayName: input.displayName, avatarId: "default", ageBand: "UNSPECIFIED" } },
          emailTokens: { create: { tokenHash: hash(`${input.email}:${verificationCode}`), expiresAt: expiresIn(15) } },
        } });
        if (config.REGISTRATION_MODE === "invite") {
          const claimed = await tx.invitation.updateMany({ where: { id: invitation!.id, usedAt: null }, data: { usedAt: new Date(), usedById: created.id } });
          if (claimed.count !== 1) throw new Error("INVALID_INVITE");
        }
        return created;
      });
      await emailer.sendVerification(account.email, verificationCode);
      return reply.code(202).send({ status: "verification_required" });
    } catch (error) {
      if (error instanceof Error && error.message === "INVALID_INVITE") return reply.code(403).send({ code: "INVALID_INVITE" });
      if (error instanceof Error && error.message === "USERNAME_UNAVAILABLE") return reply.code(409).send({ code: "USERNAME_UNAVAILABLE" });
      request.log.warn({ err: error }, "registration rejected");
      return reply.code(409).send({ code: "ACCOUNT_OR_USERNAME_UNAVAILABLE" });
    }
  });

  app.post("/v1/auth/verify-email", { config: { rateLimit: { max: 10, timeWindow: "15 minutes" } } }, async (request, reply) => {
    const input = verifySchema.parse(request.body);
    const account = await db.account.findUnique({ where: { email: input.email } });
    if (!account) return reply.code(400).send({ code: "INVALID_OR_EXPIRED_CODE" });
    const token = await db.emailVerificationToken.findFirst({ where: { accountId: account.id, usedAt: null }, orderBy: { createdAt: "desc" } });
    if (!token || token.expiresAt <= new Date() || token.attempts >= 5 || !safeHashEquals(token.tokenHash, hash(`${input.email}:${input.code}`))) {
      if (token) await db.emailVerificationToken.update({ where: { id: token.id }, data: { attempts: { increment: 1 } } });
      return reply.code(400).send({ code: "INVALID_OR_EXPIRED_CODE" });
    }
    await db.$transaction([
      db.emailVerificationToken.update({ where: { id: token.id }, data: { usedAt: new Date() } }),
      db.account.update({ where: { id: account.id }, data: { status: "ACTIVE", emailVerifiedAt: new Date() } }),
    ]);
    return reply.send({ status: "verified" });
  });

  app.post("/v1/auth/resend-verification", { config: { rateLimit: { max: 3, timeWindow: "1 hour" } } }, async (request, reply) => {
    const { email } = forgotSchema.parse(request.body);
    const account = await db.account.findUnique({ where: { email } });
    if (account && account.status === "PENDING_EMAIL") {
      const verificationCode = code();
      await db.emailVerificationToken.create({ data: { accountId: account.id, tokenHash: hash(`${email}:${verificationCode}`), expiresAt: expiresIn(15) } });
      await emailer.sendVerification(email, verificationCode);
    }
    return reply.code(202).send({ status: "accepted" });
  });

  app.post("/v1/auth/login", { config: { rateLimit: { max: 10, timeWindow: "15 minutes" } } }, async (request, reply) => {
    const input = loginSchema.parse(request.body);
    const account = await db.account.findUnique({ where: { email: input.email } });
    if (!account || account.status !== "ACTIVE" || !(await argon2.verify(account.passwordHash, input.password))) return reply.code(401).send({ code: "INVALID_CREDENTIALS" });
    return reply.send(await issueSession(app, db, config, account.id));
  });

  app.post("/v1/auth/refresh", async (request, reply) => {
    const { refreshToken } = refreshSchema.parse(request.body);
    const [id] = refreshToken.split(".", 1);
    if (!id) return reply.code(401).send({ code: "INVALID_SESSION" });
    const session = await db.authSession.findUnique({ where: { id } });
    if (!session || session.expiresAt <= new Date()) return reply.code(401).send({ code: "INVALID_SESSION" });
    if (session.revokedAt || !safeHashEquals(session.refreshTokenHash, hash(refreshToken))) {
      await db.authSession.updateMany({ where: { familyId: session.familyId }, data: { revokedAt: new Date() } });
      return reply.code(401).send({ code: "SESSION_REUSE_DETECTED" });
    }
    const claimed = await db.authSession.updateMany({ where: { id: session.id, revokedAt: null, refreshTokenHash: hash(refreshToken), expiresAt: { gt: new Date() } }, data: { revokedAt: new Date(), lastUsedAt: new Date() } });
    if (claimed.count !== 1) {
      await db.authSession.updateMany({ where: { familyId: session.familyId }, data: { revokedAt: new Date() } });
      return reply.code(401).send({ code: "SESSION_REUSE_DETECTED" });
    }
    const next = await issueSession(app, db, config, session.accountId, session.familyId);
    const nextId = next.refreshToken.split(".", 1)[0];
    if (!nextId) throw new Error("Failed to create replacement session");
    await db.authSession.update({ where: { id: session.id }, data: { replacedById: nextId } });
    return reply.send(next);
  });

  app.post("/v1/auth/logout", async (request, reply) => {
    const { refreshToken } = refreshSchema.parse(request.body);
    const [id] = refreshToken.split(".", 1);
    if (id) await db.authSession.updateMany({ where: { id }, data: { revokedAt: new Date() } });
    return reply.code(204).send();
  });

  app.post("/v1/auth/forgot-password", { config: { rateLimit: { max: 3, timeWindow: "1 hour" } } }, async (request, reply) => {
    const { email } = forgotSchema.parse(request.body);
    const account = await db.account.findUnique({ where: { email, status: "ACTIVE" } });
    if (account) {
      const resetCode = code();
      await db.passwordResetToken.create({ data: { accountId: account.id, tokenHash: hash(`${email}:${resetCode}`), expiresAt: expiresIn(15) } });
      await emailer.sendPasswordReset(email, resetCode);
    }
    return reply.code(202).send({ status: "accepted" });
  });

  app.post("/v1/auth/reset-password", async (request, reply) => {
    const input = resetSchema.parse(request.body);
    const account = await db.account.findUnique({ where: { email: input.email } });
    if (!account) return reply.code(400).send({ code: "INVALID_OR_EXPIRED_CODE" });
    const token = await db.passwordResetToken.findFirst({ where: { accountId: account.id, usedAt: null }, orderBy: { createdAt: "desc" } });
    if (!token || token.expiresAt <= new Date() || token.attempts >= 5 || !safeHashEquals(token.tokenHash, hash(`${input.email}:${input.code}`))) {
      if (token) await db.passwordResetToken.update({ where: { id: token.id }, data: { attempts: { increment: 1 } } });
      return reply.code(400).send({ code: "INVALID_OR_EXPIRED_CODE" });
    }
    await db.$transaction([
      db.passwordResetToken.update({ where: { id: token.id }, data: { usedAt: new Date() } }),
      db.account.update({ where: { id: account.id }, data: { passwordHash: await argon2.hash(input.password) } }),
      db.authSession.updateMany({ where: { accountId: account.id }, data: { revokedAt: new Date() } }),
    ]);
    return reply.send({ status: "password_reset" });
  });

  app.get("/v1/account", async (request, reply) => {
    const id = await accountId(request);
    const account = await db.account.findUnique({ where: { id }, select: { id: true, email: true, emailVerifiedAt: true, role: true, status: true, profiles: { select: { id: true, username: true, displayName: true, avatarId: true } } } });
    if (!account) return reply.code(404).send({ code: "ACCOUNT_NOT_FOUND" });
    return reply.send({ ...account, verified: config.OWNER_ACCOUNT_ID === account.id });
  });

  app.patch("/v1/profile", async (request, reply) => {
    const id = await accountId(request);
    const input = profileSchema.parse(request.body);
    const profile = await db.playerProfile.findFirst({ where: { ownerAccountId: id } });
    if (!profile) return reply.code(404).send({ code: "PROFILE_NOT_FOUND" });
    return reply.send(await db.playerProfile.update({ where: { id: profile.id }, data: { displayName: input.displayName }, select: { id: true, username: true, displayName: true, avatarId: true } }));
  });
}
