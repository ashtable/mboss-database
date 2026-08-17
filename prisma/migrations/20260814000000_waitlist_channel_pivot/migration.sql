-- The pivot: the waitlist is a communication channel, not a gate.
-- Safe-destructive: no deployed environment exists and local dev databases are disposable, so this
-- drops "User" outright rather than carrying an invite-gate table nothing will ever read again.

-- CreateEnum
CREATE TYPE "SubscriberStatus" AS ENUM ('subscribed', 'paused', 'unsubscribed', 'bounced');

-- CreateEnum
CREATE TYPE "SubscriberSource" AS ENUM ('email', 'admin');

-- CreateEnum
CREATE TYPE "BroadcastStatus" AS ENUM ('draft', 'sending', 'sent', 'failed');

-- CreateEnum
CREATE TYPE "DeliveryStatus" AS ENUM ('pending', 'sent', 'failed', 'skipped');

-- DropTable
DROP TABLE "User";

-- DropEnum
DROP TYPE "IdentitySource";

-- DropEnum
DROP TYPE "SerialKeyStatus";

-- DropEnum
DROP TYPE "UserRole";

-- DropEnum
DROP TYPE "UserStatus";

-- CreateTable
CREATE TABLE "Subscriber" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "status" "SubscriberStatus" NOT NULL DEFAULT 'subscribed',
    "source" "SubscriberSource" NOT NULL DEFAULT 'email',
    "tokenVersion" INTEGER NOT NULL DEFAULT 1,
    "confirmationEmailSentAt" TIMESTAMP(3),
    "pausedAt" TIMESTAMP(3),
    "unsubscribedAt" TIMESTAMP(3),
    "bouncedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Subscriber_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Broadcast" (
    "id" TEXT NOT NULL,
    "subject" TEXT NOT NULL,
    "bodyMarkdown" TEXT NOT NULL,
    "audience" "SubscriberStatus"[],
    "teaserImageUrl" TEXT,
    "status" "BroadcastStatus" NOT NULL DEFAULT 'draft',
    "createdBy" TEXT NOT NULL,
    "recipientCount" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "startedAt" TIMESTAMP(3),
    "completedAt" TIMESTAMP(3),

    CONSTRAINT "Broadcast_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BroadcastDelivery" (
    "id" TEXT NOT NULL,
    "broadcastId" TEXT NOT NULL,
    "subscriberId" TEXT NOT NULL,
    "status" "DeliveryStatus" NOT NULL DEFAULT 'pending',
    "error" TEXT,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "BroadcastDelivery_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Subscriber_email_key" ON "Subscriber"("email");

-- CreateIndex
CREATE INDEX "Subscriber_status_createdAt_idx" ON "Subscriber"("status", "createdAt");

-- CreateIndex
CREATE INDEX "Broadcast_createdAt_idx" ON "Broadcast"("createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "BroadcastDelivery_broadcastId_subscriberId_key" ON "BroadcastDelivery"("broadcastId", "subscriberId");

-- AddForeignKey
ALTER TABLE "BroadcastDelivery" ADD CONSTRAINT "BroadcastDelivery_broadcastId_fkey" FOREIGN KEY ("broadcastId") REFERENCES "Broadcast"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BroadcastDelivery" ADD CONSTRAINT "BroadcastDelivery_subscriberId_fkey" FOREIGN KEY ("subscriberId") REFERENCES "Subscriber"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
