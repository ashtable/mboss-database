-- CreateEnum
CREATE TYPE "UserStatus" AS ENUM ('waiting', 'invited', 'active', 'disabled');

-- CreateEnum
CREATE TYPE "IdentitySource" AS ENUM ('email', 'github');

-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('user', 'admin');

-- CreateEnum
CREATE TYPE "SerialKeyStatus" AS ENUM ('active', 'revoked');

-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "githubId" TEXT,
    "source" "IdentitySource" NOT NULL,
    "status" "UserStatus" NOT NULL DEFAULT 'waiting',
    "role" "UserRole" NOT NULL DEFAULT 'user',
    "plan" TEXT NOT NULL DEFAULT 'premium',
    "firstName" TEXT,
    "lastName" TEXT,
    "city" TEXT,
    "state" TEXT,
    "country" TEXT,
    "confirmationEmailSentAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE UNIQUE INDEX "User_githubId_key" ON "User"("githubId");

-- CreateIndex
CREATE INDEX "User_status_createdAt_idx" ON "User"("status", "createdAt");
