-- AlterTable
ALTER TABLE "Ticket" ADD COLUMN "details" TEXT;

-- CreateTable
CREATE TABLE "Lookup" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "type" TEXT NOT NULL,
    "value" TEXT NOT NULL,
    "order" INTEGER NOT NULL DEFAULT 0,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);

-- CreateIndex
CREATE INDEX "Lookup_type_value_idx" ON "Lookup"("type", "value");

-- CreateIndex
CREATE UNIQUE INDEX "Lookup_type_value_key" ON "Lookup"("type", "value");
