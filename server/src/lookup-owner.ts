import { prisma } from "./prisma.js";

const email = (process.argv[2] ?? "").trim().toLowerCase();
if (!email) throw new Error("Usage: npm run owner:lookup -- account@example.com");

const account = await prisma.account.findUnique({
  where: { email },
  select: { id: true, status: true, emailVerifiedAt: true, profiles: { select: { normalizedUsername: true } } },
});

if (!account || account.status !== "ACTIVE" || !account.emailVerifiedAt || account.profiles[0]?.normalizedUsername !== "glitch") {
  throw new Error("The owner account must be verified, active, and use the reserved Glitch username.");
}

console.log(`OWNER_ACCOUNT_ID=${account.id}`);
await prisma.$disconnect();
