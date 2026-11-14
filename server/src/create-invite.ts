import { createHash, randomBytes } from "node:crypto";
import { prisma } from "./prisma.js";

const days = Number.parseInt(process.argv[2] ?? "7", 10);
if (!Number.isInteger(days) || days < 1 || days > 30) throw new Error("Usage: npm run invite:create -- [days 1-30]");

const code = `BP-${randomBytes(12).toString("base64url")}`;
await prisma.invitation.create({ data: { codeHash: createHash("sha256").update(code).digest("hex"), expiresAt: new Date(Date.now() + days * 86_400_000), label: "staging tester" } });
console.log(`Invite (shown once): ${code}`);
await prisma.$disconnect();
