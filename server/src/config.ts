import { z } from "zod";

const booleanString = z.enum(["true", "false"]).transform((value) => value === "true");

export const configSchema = z.object({
  NODE_ENV: z.enum(["development", "test", "production"]).default("development"),
  HOST: z.string().default("127.0.0.1"),
  PORT: z.coerce.number().int().min(1).max(65535).default(3000),
  DATABASE_URL: z.string().min(1),
  JWT_SECRET: z.string().min(32),
  CHILD_ONLINE_ENABLED: booleanString.default(false),
  CHAT_ENABLED: booleanString.default(false),
  PAYMENTS_ENABLED: booleanString.default(false),
  VOICE_ENABLED: booleanString.default(false),
  REGISTRATION_MODE: z.enum(["closed", "invite", "public"]).default("closed"),
  ACCESS_TOKEN_MINUTES: z.coerce.number().int().min(5).max(60).default(15),
  REFRESH_TOKEN_DAYS: z.coerce.number().int().min(1).max(90).default(30),
  SMTP_HOST: z.string().optional(),
  SMTP_PORT: z.coerce.number().int().min(1).max(65535).default(1025),
  SMTP_USER: z.string().optional(),
  SMTP_PASS: z.string().optional(),
  SMTP_FROM: z.string().min(3).default("Battle Pets <accounts@battlepets.invalid>"),
  OWNER_ACCOUNT_ID: z.string().uuid().optional(),
});

export type ServerConfig = z.infer<typeof configSchema>;

export function loadConfig(environment: NodeJS.ProcessEnv = process.env): ServerConfig {
  return configSchema.parse(environment);
}
