import { Router } from 'express';
import { z } from 'zod';
import { PrismaClient } from '@prisma/client';
import { bus } from '../events.js';
export const publicRouter = Router();
const prisma = new PrismaClient();
// Generate unique ticket number: PDS-yyyy-m-dd-0000000
async function generateTicketNumber() {
    const now = new Date();
    const year = now.getFullYear();
    const month = now.getMonth() + 1;
    const day = now.getDate();
    // Get count of tickets created today
    const startOfDay = new Date(year, month - 1, day);
    const endOfDay = new Date(year, month - 1, day + 1);
    const count = await prisma.ticket.count({
        where: {
            createdAt: {
                gte: startOfDay,
                lt: endOfDay,
            }
        }
    });
    // Format: PDS-yyyy-m-dd-0000000 (7 digits)
    const sequence = String(count + 1).padStart(7, '0');
    return `PDS-${year}-${month}-${day}-${sequence}`;
}
const createRequestSchema = z.object({
    title: z.string().min(3).max(200),
    description: z.string().min(5).max(5000),
    requesterEmail: z.string().email(),
    requesterName: z.string().min(2).max(100).optional(),
    // optional initial SLA target in hours
    targetSlaHours: z.number().int().positive().max(24 * 90).optional(),
    details: z.record(z.any()).optional(),
});
publicRouter.post('/requests', async (req, res) => {
    const parseResult = createRequestSchema.safeParse(req.body);
    if (!parseResult.success) {
        return res.status(400).json({ error: 'Invalid payload', details: parseResult.error.flatten() });
    }
    const { title, description, requesterEmail, requesterName, targetSlaHours, details } = parseResult.data;
    const now = new Date();
    const ticketNumber = await generateTicketNumber();
    const ticket = await prisma.ticket.create({
        data: {
            ticketNumber,
            title,
            description,
            requesterEmail,
            requesterName: requesterName ?? null,
            status: 'SUBMITTED',
            totalSlaHours: targetSlaHours ?? null,
            details: details ? JSON.stringify(details) : null,
            stages: {
                create: [
                    {
                        name: 'Submitted',
                        key: 'SUBMITTED',
                        order: 1,
                        startedAt: now,
                        dueAt: null,
                    },
                ],
            },
        },
        include: { stages: true },
    });
    // emit creation event
    bus.emit('event', { type: 'ticket.created', payload: { id: ticket.id, status: ticket.status } });
    return res.status(201).json({ id: ticket.id, status: ticket.status });
});
//# sourceMappingURL=public.js.map