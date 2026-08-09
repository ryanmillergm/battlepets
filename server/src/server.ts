import cors from "@fastify/cors";
import websocket from "@fastify/websocket";
import Fastify from "fastify";
import { loadConfig } from "./config.js";

export function buildServer() {
  const app = Fastify({ logger: true });
  app.register(cors, { origin: false });
  app.register(websocket);

  app.get("/health", async () => ({ status: "ok", service: "battlepets-server", version: 1 }));
  app.get("/v1/features", async () => {
    const config = loadConfig();
    return {
      childOnline: config.CHILD_ONLINE_ENABLED,
      chat: config.CHAT_ENABLED,
      payments: config.PAYMENTS_ENABLED,
      voice: config.VOICE_ENABLED,
    };
  });

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
  const app = buildServer();
  await app.listen({ host: config.HOST, port: config.PORT });
}
