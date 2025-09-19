import { Router, Request, Response } from 'express';
import { z } from 'zod';
import { PrismaClient } from '@prisma/client';

export const ticketsRouter = Router();
const prisma = new PrismaClient();

// GET /tickets?status=CREATED&page=1&pageSize=10
ticketsRouter.get('/', async (req: Request, res: Response) => {
  const status = typeof req.query.status === 'string' ? req.query.status : undefined;
  const page = Math.max(1, parseInt(String(req.query.page ?? '1'), 10) || 1);
  const pageSize = Math.min(100, Math.max(1, parseInt(String(req.query.pageSize ?? '10'), 10) || 10));
  const skip = (page - 1) * pageSize;

  const where = status ? { status } : {};

  const [total, rows] = await Promise.all([
    prisma.ticket.count({ where }),
    prisma.ticket.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      skip,
      take: pageSize,
      select: {
        id: true,
        title: true,
        status: true,
        totalSlaHours: true,
        createdAt: true,
        updatedAt: true,
        requesterEmail: true,
        requesterName: true,
      },
    }),
  ]);

  return res.json({
    data: rows,
    pagination: {
      page,
      pageSize,
      total,
      totalPages: Math.max(1, Math.ceil(total / pageSize)),
    },
    filters: { status: status ?? null },
  });
});

// GET /tickets/:id
ticketsRouter.get('/:id', async (req: Request, res: Response) => {
  const { id } = req.params;
  const ticket = await prisma.ticket.findUnique({
    where: { id },
    include: { stages: { orderBy: { order: 'asc' } } },
  });
  if (!ticket) return res.status(404).json({ error: 'Not found' });
  return res.json(ticket);
});

// POST /tickets/:id/transition
// Body: { to: 'ANALYSIS' | 'RAT_MEETING' | 'CONFIRM_DUE' | 'DEVELOPMENT' | 'TESTING' | 'SYSTEM_IMPLEMENTATION' | 'DELIVERED' | 'REJECTED', dueAt?: string, slaHours?: number, decision?: string, comment?: string }
const transitionSchema = z.object({
  to: z.enum(['ANALYSIS','RAT_MEETING','CONFIRM_DUE','DEVELOPMENT','TESTING','SYSTEM_IMPLEMENTATION','DELIVERED','REJECTED']),
  dueAt: z.string().datetime().optional(),
  slaHours: z.number().int().positive().optional(),
  decision: z.string().optional(),
  comment: z.string().max(2000).optional(),
});

const allowedNext: Record<string, string[]> = {
  PENDING_REVIEW: ['ANALYSIS','REJECTED'],
  REJECTED: [],
  ANALYSIS: ['RAT_MEETING','CONFIRM_DUE'],
  RAT_MEETING: ['CONFIRM_DUE'],
  CONFIRM_DUE: ['DEVELOPMENT'],
  DEVELOPMENT: ['TESTING'],
  TESTING: ['SYSTEM_IMPLEMENTATION'],
  SYSTEM_IMPLEMENTATION: ['DELIVERED'],
  DELIVERED: [],
};

ticketsRouter.post('/:id/transition', async (req: Request, res: Response) => {
  const { id } = req.params;
  const parse = transitionSchema.safeParse(req.body ?? {});
  if (!parse.success) return res.status(400).json({ error: 'Invalid payload', details: parse.error.flatten() });
  const { to, dueAt, slaHours, decision, comment } = parse.data;

  const existing = await prisma.ticket.findUnique({ where: { id }, include: { stages: { orderBy: { order: 'asc' } } } });
  if (!existing) return res.status(404).json({ error: 'Not found' });

  const nexts = allowedNext[existing.status] ?? [];
  if (!nexts.includes(to)) return res.status(400).json({ error: `Invalid transition from ${existing.status} to ${to}` });

  const now = new Date();
  const nextOrder = (existing.stages.at(-1)?.order ?? 0) + 1;

  // compute SLA hours automatically on CONFIRM_DUE if dueAt provided
  let computedSla: number | null = null;
  if (to === 'CONFIRM_DUE' && dueAt) {
    const deltaMs = new Date(dueAt).getTime() - now.getTime();
    if (deltaMs > 0) computedSla = Math.ceil(deltaMs / (60 * 60 * 1000));
  }

  const updated = await prisma.ticket.update({
    where: { id },
    data: {
      status: to,
      stages: {
        create: {
          name: to.replace(/_/g, ' ').toLowerCase().replace(/\b\w/g, c => c.toUpperCase()),
          key: to,
          order: nextOrder,
          startedAt: now,
          dueAt: dueAt ? new Date(dueAt) : null,
          slaHours: typeof slaHours === 'number' ? slaHours : (computedSla ?? null),
          decision: decision ?? null,
          comment: comment ?? null,
        },
      },
      ...(to === 'CONFIRM_DUE' && ((computedSla ?? null) || typeof slaHours === 'number')
        ? { totalSlaHours: (computedSla ?? (slaHours as number)) }
        : {}),
    },
    include: { stages: { orderBy: { order: 'asc' } } },
  });

  return res.json(updated);
});


