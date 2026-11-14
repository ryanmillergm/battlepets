import { PrismaClient } from "@prisma/client";
import { createHash } from "node:crypto";
import { afterAll, beforeEach, describe, expect, it } from "vitest";
import { loadConfig } from "../src/config.js";
import type { AccountEmail } from "../src/email.js";
import { buildServer } from "../src/server.js";

const enabled = process.env.RUN_DATABASE_TESTS === "true";
const db = new PrismaClient();
let verificationCode = "";
let resetCode = "";
const emailer: AccountEmail = {
  async sendVerification(_email, code) { verificationCode = code; },
  async sendPasswordReset(_email, code) { resetCode = code; },
};
const config = loadConfig({
  NODE_ENV: "test",
  DATABASE_URL: process.env.DATABASE_URL ?? "postgresql://unused:unused@127.0.0.1:5432/unused",
  JWT_SECRET: "test-secret-that-is-at-least-thirty-two-characters",
  REGISTRATION_MODE: "invite",
});

describe.skipIf(!enabled)("account API", () => {
  beforeEach(async () => {
    await db.authSession.deleteMany();
    await db.passwordResetToken.deleteMany();
    await db.emailVerificationToken.deleteMany();
    await db.invitation.deleteMany();
    await db.playerProfile.deleteMany();
    await db.account.deleteMany();
    verificationCode = "";
    resetCode = "";
  });

  afterAll(async () => { await db.$disconnect(); });

  it("registers with a one-use invitation, verifies, logs in, and rotates a session", async () => {
    const inviteCode = "BP-test-invite-code";
    await db.invitation.create({ data: { codeHash: createHash("sha256").update(inviteCode).digest("hex"), expiresAt: new Date(Date.now() + 60_000) } });
    const app = buildServer({ config, db, emailer });

    const registration = await app.inject({ method: "POST", url: "/v1/auth/register", payload: { inviteCode, email: "PLAYER@example.com", password: "correct horse battery staple", username: "TestPlayer", displayName: "Test Player" } });
    expect(registration.statusCode).toBe(202);
    expect(verificationCode).toMatch(/^\d{6}$/);

    const reused = await app.inject({ method: "POST", url: "/v1/auth/register", payload: { inviteCode, email: "other@example.com", password: "correct horse battery staple", username: "OtherPlayer", displayName: "Other" } });
    expect(reused.statusCode).toBe(403);

    const verified = await app.inject({ method: "POST", url: "/v1/auth/verify-email", payload: { email: "player@example.com", code: verificationCode } });
    expect(verified.statusCode).toBe(200);

    const login = await app.inject({ method: "POST", url: "/v1/auth/login", payload: { email: "player@example.com", password: "correct horse battery staple" } });
    expect(login.statusCode).toBe(200);
    const tokens = login.json<{ accessToken: string; refreshToken: string }>();

    const account = await app.inject({ method: "GET", url: "/v1/account", headers: { authorization: `Bearer ${tokens.accessToken}` } });
    expect(account.statusCode).toBe(200);
    expect(account.json().profiles[0]).toMatchObject({ username: "TestPlayer", displayName: "Test Player" });

    const refresh = await app.inject({ method: "POST", url: "/v1/auth/refresh", payload: { refreshToken: tokens.refreshToken } });
    expect(refresh.statusCode).toBe(200);
    expect(refresh.json().refreshToken).not.toBe(tokens.refreshToken);

    const reuse = await app.inject({ method: "POST", url: "/v1/auth/refresh", payload: { refreshToken: tokens.refreshToken } });
    expect(reuse.statusCode).toBe(401);
    expect(reuse.json()).toMatchObject({ code: "SESSION_REUSE_DETECTED" });
    await app.close();
  });

  it("resets a password and revokes existing sessions", async () => {
    const inviteCode = "BP-second-invite-code";
    await db.invitation.create({ data: { codeHash: createHash("sha256").update(inviteCode).digest("hex"), expiresAt: new Date(Date.now() + 60_000) } });
    const app = buildServer({ config, db, emailer });
    await app.inject({ method: "POST", url: "/v1/auth/register", payload: { inviteCode, email: "reset@example.com", password: "first password is long", username: "ResetPlayer", displayName: "Reset" } });
    await app.inject({ method: "POST", url: "/v1/auth/verify-email", payload: { email: "reset@example.com", code: verificationCode } });
    const login = await app.inject({ method: "POST", url: "/v1/auth/login", payload: { email: "reset@example.com", password: "first password is long" } });
    const oldRefresh = login.json<{ refreshToken: string }>().refreshToken;

    const forgot = await app.inject({ method: "POST", url: "/v1/auth/forgot-password", payload: { email: "reset@example.com" } });
    expect(forgot.statusCode).toBe(202);
    expect(resetCode).toMatch(/^\d{6}$/);
    const reset = await app.inject({ method: "POST", url: "/v1/auth/reset-password", payload: { email: "reset@example.com", code: resetCode, password: "second password is longer" } });
    expect(reset.statusCode).toBe(200);
    expect((await app.inject({ method: "POST", url: "/v1/auth/refresh", payload: { refreshToken: oldRefresh } })).statusCode).toBe(401);
    expect((await app.inject({ method: "POST", url: "/v1/auth/login", payload: { email: "reset@example.com", password: "second password is longer" } })).statusCode).toBe(200);
    await app.close();
  });
});
