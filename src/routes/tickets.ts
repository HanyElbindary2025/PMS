import { Router, Request, Response } from 'express';
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


