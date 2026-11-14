import nodemailer from "nodemailer";
import type { ServerConfig } from "./config.js";

export interface AccountEmail {
  sendVerification(email: string, code: string): Promise<void>;
  sendPasswordReset(email: string, code: string): Promise<void>;
}

export function createAccountEmail(config: ServerConfig): AccountEmail {
  if (!config.SMTP_HOST) {
    if (config.NODE_ENV === "production") throw new Error("SMTP_HOST is required in production");
    return {
      async sendVerification(email, code) { console.info(`[development email] verify ${email}: ${code}`); },
      async sendPasswordReset(email, code) { console.info(`[development email] reset ${email}: ${code}`); },
    };
  }

  const auth = config.SMTP_USER && config.SMTP_PASS ? { user: config.SMTP_USER, pass: config.SMTP_PASS } : undefined;
  const transport = nodemailer.createTransport({ host: config.SMTP_HOST, port: config.SMTP_PORT, secure: config.SMTP_PORT === 465, auth });
  return {
    async sendVerification(email, code) {
      await transport.sendMail({ from: config.SMTP_FROM, to: email, subject: "Verify your Battle Pets test account", text: `Your Battle Pets verification code is ${code}. It expires in 15 minutes.` });
    },
    async sendPasswordReset(email, code) {
      await transport.sendMail({ from: config.SMTP_FROM, to: email, subject: "Reset your Battle Pets password", text: `Your Battle Pets password reset code is ${code}. It expires in 15 minutes. If you did not request this, ignore this email.` });
    },
  };
}
