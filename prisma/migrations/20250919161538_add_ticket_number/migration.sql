/*
  Warnings:

  - Added the required column `ticketNumber` to the `Ticket` table without a default value. This is not possible if the table is not empty.

*/
-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_Ticket" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "ticketNumber" TEXT NOT NULL,
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
INSERT INTO "new_Ticket" ("acceptanceCriteria", "architecture", "assignedToId", "blockers", "businessJustification", "businessValue", "category", "closureReason", "createdAt", "createdById", "currentPhase", "customerSatisfaction", "dependencies", "description", "details", "effortEstimate", "escalationLevel", "id", "impact", "lessonsLearned", "priority", "progressPercentage", "qualityGates", "requesterEmail", "requesterName", "riskAssessment", "service", "slaBreachRisk", "status", "subcategory", "teamMembers", "technicalAnalysis", "testResults", "title", "totalSlaHours", "updatedAt", "urgency", "ticketNumber") 
SELECT "acceptanceCriteria", "architecture", "assignedToId", "blockers", "businessJustification", "businessValue", "category", "closureReason", "createdAt", "createdById", "currentPhase", "customerSatisfaction", "dependencies", "description", "details", "effortEstimate", "escalationLevel", "id", "impact", "lessonsLearned", "priority", "progressPercentage", "qualityGates", "requesterEmail", "requesterName", "riskAssessment", "service", "slaBreachRisk", "status", "subcategory", "teamMembers", "technicalAnalysis", "testResults", "title", "totalSlaHours", "updatedAt", "urgency", 
'PDS-' || strftime('%Y', "createdAt") || '-' || strftime('%m', "createdAt") || '-' || strftime('%d', "createdAt") || '-' || printf('%07d', ROW_NUMBER() OVER (ORDER BY "createdAt")) 
FROM "Ticket";
DROP TABLE "Ticket";
ALTER TABLE "new_Ticket" RENAME TO "Ticket";
CREATE UNIQUE INDEX "Ticket_ticketNumber_key" ON "Ticket"("ticketNumber");
CREATE INDEX "Ticket_assignedToId_idx" ON "Ticket"("assignedToId");
CREATE INDEX "Ticket_status_assignedToId_idx" ON "Ticket"("status", "assignedToId");
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
