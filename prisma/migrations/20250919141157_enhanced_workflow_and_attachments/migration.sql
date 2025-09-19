-- AlterTable
ALTER TABLE "Stage" ADD COLUMN "approver" TEXT;
ALTER TABLE "Stage" ADD COLUMN "assignee" TEXT;
ALTER TABLE "Stage" ADD COLUMN "attachments" TEXT;
ALTER TABLE "Stage" ADD COLUMN "phaseData" TEXT;

-- CreateTable
CREATE TABLE "Attachment" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "ticketId" TEXT NOT NULL,
    "stageId" TEXT,
    "fileName" TEXT NOT NULL,
    "originalName" TEXT NOT NULL,
    "fileSize" INTEGER NOT NULL,
    "mimeType" TEXT NOT NULL,
    "filePath" TEXT NOT NULL,
    "category" TEXT,
    "description" TEXT,
    "uploadedBy" TEXT NOT NULL,
    "uploadedAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "Attachment_ticketId_fkey" FOREIGN KEY ("ticketId") REFERENCES "Ticket" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_Ticket" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "requesterEmail" TEXT NOT NULL,
    "requesterName" TEXT,
    "status" TEXT NOT NULL DEFAULT 'SUBMITTED',
    "totalSlaHours" INTEGER,
    "details" TEXT,
    "priority" TEXT,
    "impact" TEXT,
    "urgency" TEXT,
    "category" TEXT,
    "subcategory" TEXT,
    "service" TEXT,
    "businessJustification" TEXT,
    "businessValue" TEXT,
    "riskAssessment" TEXT,
    "technicalAnalysis" TEXT,
    "dependencies" TEXT,
    "effortEstimate" TEXT,
    "architecture" TEXT,
    "currentPhase" TEXT,
    "progressPercentage" INTEGER DEFAULT 0,
    "blockers" TEXT,
    "slaBreachRisk" TEXT,
    "qualityGates" TEXT,
    "acceptanceCriteria" TEXT,
    "testResults" TEXT,
    "closureReason" TEXT,
    "lessonsLearned" TEXT,
    "customerSatisfaction" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);
INSERT INTO "new_Ticket" ("createdAt", "description", "details", "id", "requesterEmail", "requesterName", "status", "title", "totalSlaHours", "updatedAt") SELECT "createdAt", "description", "details", "id", "requesterEmail", "requesterName", "status", "title", "totalSlaHours", "updatedAt" FROM "Ticket";
DROP TABLE "Ticket";
ALTER TABLE "new_Ticket" RENAME TO "Ticket";
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;

-- CreateIndex
CREATE INDEX "Attachment_ticketId_idx" ON "Attachment"("ticketId");

-- CreateIndex
CREATE INDEX "Attachment_stageId_idx" ON "Attachment"("stageId");
