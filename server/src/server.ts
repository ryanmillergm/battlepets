import cors from "@fastify/cors";
import jwt from "@fastify/jwt";
import rateLimit from "@fastify/rate-limit";
import websocket from "@fastify/websocket";
import type { PrismaClient } from "@prisma/client";
import Fastify from "fastify";
import { ZodError } from "zod";
import { registerAuthRoutes } from "./auth.js";
import { loadConfig, type ServerConfig } from "./config.js";
import { createAccountEmail, type AccountEmail } from "./email.js";
import { prisma } from "./prisma.js";

export interface ServerDependencies {
  config?: ServerConfig;
  db?: PrismaClient;
  emailer?: AccountEmail;
}

export function buildServer(dependencies: ServerDependencies = {}) {
  const config = dependencies.config ?? loadConfig();
  const db = dependencies.db ?? prisma;
  const emailer = dependencies.emailer ?? createAccountEmail(config);
  const app = Fastify({ logger: true });
  app.register(cors, { origin: false });
  app.register(websocket);
  app.register(jwt, { secret: config.JWT_SECRET });
  app.register(rateLimit, { global: false });

  app.setErrorHandler((error, request, reply) => {
    if (error instanceof ZodError) return reply.code(400).send({ code: "INVALID_REQUEST", issues: error.issues.map((issue) => ({ path: issue.path.join("."), message: issue.message })) });
    request.log.error({ err: error }, "request failed");
    const statusCode = typeof error === "object" && error !== null && "statusCode" in error && typeof error.statusCode === "number" && error.statusCode < 500 ? error.statusCode : 500;
    return reply.code(statusCode).send({ code: statusCode < 500 ? "REQUEST_FAILED" : "INTERNAL_ERROR" });
  });

  app.get("/health", async () => ({ status: "ok", service: "battlepets-server", version: 1 }));
  app.get("/v1/features", async () => {
    return {
      childOnline: config.CHILD_ONLINE_ENABLED,
      chat: config.CHAT_ENABLED,
      payments: config.PAYMENTS_ENABLED,
      voice: config.VOICE_ENABLED,
    };
  });

  registerAuthRoutes(app, db, config, emailer);

  app.get("/v1/ws", { websocket: true }, (socket) => {
    socket.send(JSON.stringify({ type: "connected", protocolVersion: 1 }));
    socket.on("message", (raw: { toString(): string }) => {
      socket.send(JSON.stringify({ type: "error", code: "NOT_AUTHENTICATED", request: raw.toString() }));
    });
  });
  return app;
}

if (process.env.NODE_ENV !== "test") {
  const config = loadConfig();
  const app = buildServer({ config });
  await app.listen({ host: config.HOST, port: config.PORT });
}
