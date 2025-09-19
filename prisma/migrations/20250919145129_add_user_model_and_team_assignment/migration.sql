-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "email" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "role" TEXT NOT NULL,
    "department" TEXT,
    "phone" TEXT,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "lastLoginAt" DATETIME,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
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
    "assignedToId" TEXT,
    "createdById" TEXT,
    "teamMembers" TEXT,
    "escalationLevel" INTEGER DEFAULT 0,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "Ticket_assignedToId_fkey" FOREIGN KEY ("assignedToId") REFERENCES "User" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT "Ticket_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "User" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);
INSERT INTO "new_Ticket" ("acceptanceCriteria", "architecture", "blockers", "businessJustification", "businessValue", "category", "closureReason", "createdAt", "currentPhase", "customerSatisfaction", "dependencies", "description", "details", "effortEstimate", "id", "impact", "lessonsLearned", "priority", "progressPercentage", "qualityGates", "requesterEmail", "requesterName", "riskAssessment", "service", "slaBreachRisk", "status", "subcategory", "technicalAnalysis", "testResults", "title", "totalSlaHours", "updatedAt", "urgency") SELECT "acceptanceCriteria", "architecture", "blockers", "businessJustification", "businessValue", "category", "closureReason", "createdAt", "currentPhase", "customerSatisfaction", "dependencies", "description", "details", "effortEstimate", "id", "impact", "lessonsLearned", "priority", "progressPercentage", "qualityGates", "requesterEmail", "requesterName", "riskAssessment", "service", "slaBreachRisk", "status", "subcategory", "technicalAnalysis", "testResults", "title", "totalSlaHours", "updatedAt", "urgency" FROM "Ticket";
DROP TABLE "Ticket";
ALTER TABLE "new_Ticket" RENAME TO "Ticket";
CREATE INDEX "Ticket_assignedToId_idx" ON "Ticket"("assignedToId");
CREATE INDEX "Ticket_status_assignedToId_idx" ON "Ticket"("status", "assignedToId");
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE INDEX "User_email_idx" ON "User"("email");

-- CreateIndex
CREATE INDEX "User_role_idx" ON "User"("role");
