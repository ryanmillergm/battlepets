import { createHash, randomBytes } from "node:crypto";
import { prisma } from "./prisma.js";

const days = Number.parseInt(process.argv[2] ?? "7", 10);
const kind = (process.argv[3] ?? "tester").toLowerCase();
if (!Number.isInteger(days) || days < 1 || days > 30 || !["tester", "owner"].includes(kind)) {
  throw new Error("Usage: npm run invite:create -- [days 1-30] [tester|owner]");
}

const code = `BP-${randomBytes(12).toString("base64url")}`;
const label = kind === "owner" ? "owner bootstrap" : "local tester";
await prisma.invitation.create({ data: { codeHash: createHash("sha256").update(code).digest("hex"), expiresAt: new Date(Date.now() + days * 86_400_000), label } });
console.log(`${kind === "owner" ? "Owner" : "Tester"} invite (shown once): ${code}`);
await prisma.$disconnect();
