CREATE TYPE "AccountRole" AS ENUM ('USER', 'MODERATOR', 'ADMIN');
CREATE TYPE "AccountStatus" AS ENUM ('PENDING_EMAIL', 'ACTIVE', 'DISABLED');
CREATE TYPE "ProfileAgeBand" AS ENUM ('UNSPECIFIED', 'CHILD', 'TEEN', 'ADULT');
CREATE TYPE "MatchMode" AS ENUM ('BOT', 'LOCAL', 'CASUAL', 'COMPETITIVE');
CREATE TYPE "LedgerKind" AS ENUM ('MATCH_REWARD', 'DIRECT_PURCHASE', 'PACK_PURCHASE', 'DUPLICATE_REDEMPTION', 'PAYMENT', 'REFUND', 'ADMIN_ADJUSTMENT');

CREATE TABLE "Account" (
    "id" TEXT NOT NULL, "email" TEXT NOT NULL, "passwordHash" TEXT NOT NULL,
    "emailVerifiedAt" TIMESTAMP(3), "role" "AccountRole" NOT NULL DEFAULT 'USER',
    "status" "AccountStatus" NOT NULL DEFAULT 'PENDING_EMAIL',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, "updatedAt" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "Account_pkey" PRIMARY KEY ("id")
);
CREATE TABLE "PlayerProfile" (
    "id" TEXT NOT NULL, "ownerAccountId" TEXT NOT NULL, "username" TEXT NOT NULL,
    "normalizedUsername" TEXT NOT NULL, "displayName" TEXT NOT NULL, "avatarId" TEXT NOT NULL,
    "ageBand" "ProfileAgeBand" NOT NULL, "chatEnabled" BOOLEAN NOT NULL DEFAULT false,
    "usernameChangedAt" TIMESTAMP(3), "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL, CONSTRAINT "PlayerProfile_pkey" PRIMARY KEY ("id")
);
CREATE TABLE "Invitation" (
    "id" TEXT NOT NULL, "codeHash" TEXT NOT NULL, "label" TEXT, "expiresAt" TIMESTAMP(3) NOT NULL,
    "usedAt" TIMESTAMP(3), "usedById" TEXT, "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "Invitation_pkey" PRIMARY KEY ("id")
);
CREATE TABLE "EmailVerificationToken" (
    "id" TEXT NOT NULL, "accountId" TEXT NOT NULL, "tokenHash" TEXT NOT NULL,
    "attempts" INTEGER NOT NULL DEFAULT 0, "expiresAt" TIMESTAMP(3) NOT NULL, "usedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "EmailVerificationToken_pkey" PRIMARY KEY ("id")
);
CREATE TABLE "PasswordResetToken" (
    "id" TEXT NOT NULL, "accountId" TEXT NOT NULL, "tokenHash" TEXT NOT NULL,
    "attempts" INTEGER NOT NULL DEFAULT 0, "expiresAt" TIMESTAMP(3) NOT NULL, "usedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "PasswordResetToken_pkey" PRIMARY KEY ("id")
);
CREATE TABLE "AuthSession" (
    "id" TEXT NOT NULL, "accountId" TEXT NOT NULL, "familyId" TEXT NOT NULL,
    "refreshTokenHash" TEXT NOT NULL, "expiresAt" TIMESTAMP(3) NOT NULL, "revokedAt" TIMESTAMP(3),
    "replacedById" TEXT, "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastUsedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "AuthSession_pkey" PRIMARY KEY ("id")
);
CREATE TABLE "ConsentReceipt" (
    "id" TEXT NOT NULL, "accountId" TEXT NOT NULL, "profileId" TEXT, "policyVersion" TEXT NOT NULL,
    "consentType" TEXT NOT NULL, "granted" BOOLEAN NOT NULL, "providerRef" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, "revokedAt" TIMESTAMP(3),
    CONSTRAINT "ConsentReceipt_pkey" PRIMARY KEY ("id")
);
CREATE TABLE "RarityDefinition" (
    "id" TEXT NOT NULL, "slug" TEXT NOT NULL, "displayName" TEXT NOT NULL, "displayOrder" INTEGER NOT NULL,
    "colorHex" TEXT NOT NULL, "active" BOOLEAN NOT NULL DEFAULT true,
    CONSTRAINT "RarityDefinition_pkey" PRIMARY KEY ("id")
);
CREATE TABLE "BattlepetDefinition" (
    "id" TEXT NOT NULL, "slug" TEXT NOT NULL, "displayName" TEXT NOT NULL,
    "contentVersion" INTEGER NOT NULL DEFAULT 1, "maxHealth" INTEGER NOT NULL, "tags" TEXT[],
    "artManifest" JSONB NOT NULL, "basicAttack" JSONB NOT NULL, "superAttack" JSONB NOT NULL,
    "ability" JSONB, "rarityId" TEXT NOT NULL, "directPrice" INTEGER NOT NULL,
    "starterEligible" BOOLEAN NOT NULL DEFAULT false, "active" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, "updatedAt" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "BattlepetDefinition_pkey" PRIMARY KEY ("id")
);
CREATE TABLE "SpecialtyCardDefinition" (
    "id" TEXT NOT NULL, "slug" TEXT NOT NULL, "displayName" TEXT NOT NULL,
    "contentVersion" INTEGER NOT NULL DEFAULT 1, "artManifest" JSONB NOT NULL, "rules" JSONB NOT NULL,
    "active" BOOLEAN NOT NULL DEFAULT false, "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL, CONSTRAINT "SpecialtyCardDefinition_pkey" PRIMARY KEY ("id")
);
CREATE TABLE "InventoryItem" (
    "profileId" TEXT NOT NULL, "battlepetId" TEXT NOT NULL, "quantity" INTEGER NOT NULL DEFAULT 1,
    "acquiredAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "InventoryItem_pkey" PRIMARY KEY ("profileId", "battlepetId")
);
CREATE TABLE "CurrencyLedger" (
    "id" TEXT NOT NULL, "accountId" TEXT NOT NULL, "profileId" TEXT, "kind" "LedgerKind" NOT NULL,
    "earnedDelta" INTEGER NOT NULL DEFAULT 0, "purchasedDelta" INTEGER NOT NULL DEFAULT 0,
    "idempotencyKey" TEXT NOT NULL, "referenceId" TEXT, "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "CurrencyLedger_pkey" PRIMARY KEY ("id")
);
CREATE TABLE "Lobby" (
    "id" TEXT NOT NULL, "hostProfileId" TEXT NOT NULL, "capacity" INTEGER NOT NULL,
    "teamSize" INTEGER NOT NULL, "turnSeconds" INTEGER NOT NULL, "mode" "MatchMode" NOT NULL,
    "fillWithBots" BOOLEAN NOT NULL DEFAULT false, "status" TEXT NOT NULL DEFAULT 'WAITING',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, "updatedAt" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "Lobby_pkey" PRIMARY KEY ("id")
);
CREATE TABLE "LobbyMember" (
    "lobbyId" TEXT NOT NULL, "profileId" TEXT NOT NULL,
    "joinedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "LobbyMember_pkey" PRIMARY KEY ("lobbyId", "profileId")
);
CREATE TABLE "Match" (
    "id" TEXT NOT NULL, "mode" "MatchMode" NOT NULL, "contentVersion" INTEGER NOT NULL,
    "state" JSONB NOT NULL, "qualifying" BOOLEAN NOT NULL DEFAULT false,
    "startedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, "completedAt" TIMESTAMP(3),
    CONSTRAINT "Match_pkey" PRIMARY KEY ("id")
);
CREATE TABLE "MatchParticipant" (
    "id" TEXT NOT NULL, "matchId" TEXT NOT NULL, "profileId" TEXT, "seat" INTEGER NOT NULL,
    "username" TEXT NOT NULL, "startedBot" BOOLEAN NOT NULL DEFAULT false,
    "endedBot" BOOLEAN NOT NULL DEFAULT false, "placement" INTEGER,
    CONSTRAINT "MatchParticipant_pkey" PRIMARY KEY ("id")
);
CREATE TABLE "MatchAction" (
    "id" TEXT NOT NULL, "matchId" TEXT NOT NULL, "sequence" INTEGER NOT NULL,
    "idempotencyKey" TEXT NOT NULL, "actorSeat" INTEGER NOT NULL, "command" JSONB NOT NULL,
    "resultingState" JSONB NOT NULL, "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "MatchAction_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "Account_email_key" ON "Account"("email");
CREATE UNIQUE INDEX "PlayerProfile_normalizedUsername_key" ON "PlayerProfile"("normalizedUsername");
CREATE UNIQUE INDEX "Invitation_codeHash_key" ON "Invitation"("codeHash");
CREATE UNIQUE INDEX "Invitation_usedById_key" ON "Invitation"("usedById");
CREATE INDEX "Invitation_expiresAt_usedAt_idx" ON "Invitation"("expiresAt", "usedAt");
CREATE UNIQUE INDEX "EmailVerificationToken_tokenHash_key" ON "EmailVerificationToken"("tokenHash");
CREATE INDEX "EmailVerificationToken_accountId_expiresAt_idx" ON "EmailVerificationToken"("accountId", "expiresAt");
CREATE UNIQUE INDEX "PasswordResetToken_tokenHash_key" ON "PasswordResetToken"("tokenHash");
CREATE INDEX "PasswordResetToken_accountId_expiresAt_idx" ON "PasswordResetToken"("accountId", "expiresAt");
CREATE UNIQUE INDEX "AuthSession_refreshTokenHash_key" ON "AuthSession"("refreshTokenHash");
CREATE INDEX "AuthSession_accountId_familyId_idx" ON "AuthSession"("accountId", "familyId");
CREATE INDEX "AuthSession_expiresAt_idx" ON "AuthSession"("expiresAt");
CREATE INDEX "ConsentReceipt_accountId_consentType_idx" ON "ConsentReceipt"("accountId", "consentType");
CREATE UNIQUE INDEX "RarityDefinition_slug_key" ON "RarityDefinition"("slug");
CREATE UNIQUE INDEX "BattlepetDefinition_slug_key" ON "BattlepetDefinition"("slug");
CREATE UNIQUE INDEX "SpecialtyCardDefinition_slug_key" ON "SpecialtyCardDefinition"("slug");
CREATE UNIQUE INDEX "CurrencyLedger_idempotencyKey_key" ON "CurrencyLedger"("idempotencyKey");
CREATE INDEX "CurrencyLedger_accountId_createdAt_idx" ON "CurrencyLedger"("accountId", "createdAt");
CREATE UNIQUE INDEX "MatchParticipant_matchId_seat_key" ON "MatchParticipant"("matchId", "seat");
CREATE UNIQUE INDEX "MatchAction_idempotencyKey_key" ON "MatchAction"("idempotencyKey");
CREATE UNIQUE INDEX "MatchAction_matchId_sequence_key" ON "MatchAction"("matchId", "sequence");

ALTER TABLE "PlayerProfile" ADD CONSTRAINT "PlayerProfile_ownerAccountId_fkey" FOREIGN KEY ("ownerAccountId") REFERENCES "Account"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "EmailVerificationToken" ADD CONSTRAINT "EmailVerificationToken_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES "Account"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "PasswordResetToken" ADD CONSTRAINT "PasswordResetToken_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES "Account"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "AuthSession" ADD CONSTRAINT "AuthSession_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES "Account"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "ConsentReceipt" ADD CONSTRAINT "ConsentReceipt_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES "Account"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "BattlepetDefinition" ADD CONSTRAINT "BattlepetDefinition_rarityId_fkey" FOREIGN KEY ("rarityId") REFERENCES "RarityDefinition"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "InventoryItem" ADD CONSTRAINT "InventoryItem_profileId_fkey" FOREIGN KEY ("profileId") REFERENCES "PlayerProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "InventoryItem" ADD CONSTRAINT "InventoryItem_battlepetId_fkey" FOREIGN KEY ("battlepetId") REFERENCES "BattlepetDefinition"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "CurrencyLedger" ADD CONSTRAINT "CurrencyLedger_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES "Account"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "LobbyMember" ADD CONSTRAINT "LobbyMember_lobbyId_fkey" FOREIGN KEY ("lobbyId") REFERENCES "Lobby"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "LobbyMember" ADD CONSTRAINT "LobbyMember_profileId_fkey" FOREIGN KEY ("profileId") REFERENCES "PlayerProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "MatchParticipant" ADD CONSTRAINT "MatchParticipant_matchId_fkey" FOREIGN KEY ("matchId") REFERENCES "Match"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "MatchParticipant" ADD CONSTRAINT "MatchParticipant_profileId_fkey" FOREIGN KEY ("profileId") REFERENCES "PlayerProfile"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "MatchAction" ADD CONSTRAINT "MatchAction_matchId_fkey" FOREIGN KEY ("matchId") REFERENCES "Match"("id") ON DELETE CASCADE ON UPDATE CASCADE;
