import { Router, Request, Response } from 'express';
import { z } from 'zod';
import { PrismaClient } from '@prisma/client';
import { calculateMTTR, getSLAPerformance } from '../sla.js';

export const ticketsRouter = Router();
const prisma = new PrismaClient();

// GET /tickets?status=CREATED&page=1&pageSize=10&requesterEmail=user@example.com
ticketsRouter.get('/', async (req: Request, res: Response) => {
  const status = typeof req.query.status === 'string' ? req.query.status : undefined;
  const priority = typeof req.query.priority === 'string' ? req.query.priority : undefined;
  const category = typeof req.query.category === 'string' ? req.query.category : undefined;
  const requesterEmail = typeof req.query.requesterEmail === 'string' ? req.query.requesterEmail : undefined;
  const page = Math.max(1, parseInt(String(req.query.page ?? '1'), 10) || 1);
  const pageSize = Math.min(100, Math.max(1, parseInt(String(req.query.pageSize ?? '10'), 10) || 10));
  const skip = (page - 1) * pageSize;

  const where: any = {};
  if (status) where.status = status;
  if (priority) where.priority = priority;
  if (category) where.category = category;
  if (requesterEmail) where.requesterEmail = requesterEmail;

  const [total, rows] = await Promise.all([
    prisma.ticket.count({ where }),
    prisma.ticket.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      skip,
      take: pageSize,
      select: {
        id: true,
        ticketNumber: true,
        title: true,
        status: true,
        priority: true,
        category: true,
        totalSlaHours: true,
        createdAt: true,
        updatedAt: true,
        requesterEmail: true,
        requesterName: true,
        assignedToId: true,
        teamMembers: true,
        assignedTo: {
          select: { id: true, name: true, email: true, role: true }
        }
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
    filters: { 
      status: status ?? null,
      priority: priority ?? null,
      category: category ?? null,
      requesterEmail: requesterEmail ?? null,
    },
  });
});

// GET /tickets/:id
ticketsRouter.get('/:id', async (req: Request, res: Response) => {
  const { id } = req.params;
  const ticket = await prisma.ticket.findUnique({
    where: { id },
    include: { 
      stages: { orderBy: { order: 'asc' } },
      assignedTo: {
        select: { id: true, name: true, email: true, role: true }
      }
    },
  });
  if (!ticket) return res.status(404).json({ error: 'Not found' });

  // Calculate SLA status
  let slaStatus = 'NO_SLA_SET';
  if (ticket.totalSlaHours) {
    // Find the stage where SLA starts (CONFIRM_DUE or first stage with SLA)
    const slaStartStage = ticket.stages.find(stage => 
      stage.key === 'CONFIRM_DUE' || 
      (stage.slaHours && stage.slaHours > 0)
    );
    
    if (slaStartStage && slaStartStage.startedAt) {
      const now = new Date();
      const slaEndTime = new Date(slaStartStage.startedAt.getTime() + (ticket.totalSlaHours * 60 * 60 * 1000));
      const timeRemaining = slaEndTime.getTime() - now.getTime();

      if (timeRemaining > 0) {
        const hoursRemaining = timeRemaining / (1000 * 60 * 60);
        if (hoursRemaining > 1) {
          slaStatus = `WITHIN_SLA_${hoursRemaining.toFixed(1)}H_REMAINING`;
        } else {
          const minutesRemaining = timeRemaining / (1000 * 60);
          slaStatus = `WITHIN_SLA_${minutesRemaining.toFixed(0)}M_REMAINING`;
        }
      } else {
        const breachTime = Math.abs(timeRemaining) / (1000 * 60 * 60);
        slaStatus = `SLA_BREACH_${breachTime.toFixed(1)}H_OVERDUE`;
      }
    } else if (ticket.status === 'CLOSED') {
      // For closed tickets, show completion status
      slaStatus = 'COMPLETED';
    }
  } else if (ticket.status === 'CLOSED') {
    // For closed tickets without SLA, show completion status
    slaStatus = 'COMPLETED';
  }

  return res.json({
    ...ticket,
    slaStatus
  });
});

// POST /tickets/:id/transition
// Body: { to: 'ANALYSIS' | 'RAT_MEETING' | 'CONFIRM_DUE' | 'DEVELOPMENT' | 'TESTING' | 'SYSTEM_IMPLEMENTATION' | 'DELIVERED' | 'REJECTED', dueAt?: string, slaHours?: number, decision?: string, comment?: string }
const transitionSchema = z.object({
  to: z.enum([
    'SUBMITTED', 'CATEGORIZED', 'PRIORITIZED', 'ANALYSIS', 'DESIGN', 'APPROVAL',
    'DEVELOPMENT', 'TESTING', 'UAT', 'DEPLOYMENT', 'VERIFICATION', 'CLOSED',
    'ON_HOLD', 'REJECTED', 'CANCELLED', 'CONFIRM_DUE', 'MEETING_REQUESTED',
    'DIGITAL_APPROVAL', 'CUSTOMER_APPROVAL'
  ]),
  dueAt: z.string().datetime().optional(),
  slaHours: z.number().int().positive().optional(),
  decision: z.string().optional(),
  comment: z.string().max(2000).optional(),
  assignedToId: z.string().optional(), // Team assignment
  teamMembers: z.array(z.string()).optional(), // Multiple team members
  priority: z.string().optional(), // Priority from confirmation dialog
  category: z.string().optional(), // Category from confirmation dialog
  userRole: z.string().optional(), // User role for permission checking
});

// Role-based workflow permissions (simplified)
const rolePermissions: Record<string, string[]> = {
  ADMIN: ['SUBMITTED', 'ANALYSIS', 'CONFIRM_DUE', 'MEETING_REQUESTED', 'DESIGN', 'DEVELOPMENT', 'TESTING', 'CUSTOMER_APPROVAL', 'DEPLOYMENT', 'VERIFICATION', 'CLOSED', 'ON_HOLD', 'REJECTED', 'CANCELLED'],
  SERVICE_MANAGER: ['ANALYSIS', 'CONFIRM_DUE', 'MEETING_REQUESTED', 'DESIGN', 'DEVELOPMENT', 'TESTING', 'CUSTOMER_APPROVAL', 'DEPLOYMENT', 'VERIFICATION', 'ON_HOLD'],
  TECHNICAL_ANALYST: ['ANALYSIS', 'CONFIRM_DUE', 'MEETING_REQUESTED', 'DESIGN', 'ON_HOLD'],
  SOLUTION_ARCHITECT: ['DESIGN', 'DEVELOPMENT', 'ON_HOLD'],
  DEVELOPER: ['DEVELOPMENT', 'TESTING', 'ON_HOLD'],
  QA_ENGINEER: ['TESTING', 'ON_HOLD'],
  DEVOPS_ENGINEER: ['DEPLOYMENT', 'VERIFICATION', 'ON_HOLD'],
  CREATOR: ['SUBMITTED', 'CUSTOMER_APPROVAL', 'VERIFICATION'], // Customer/Requester can approve customer approval and final verification
};

const allowedNext: Record<string, string[]> = {
  // Simplified workflow based on user requirements
  SUBMITTED: ['ANALYSIS', 'REJECTED'], // Admin accepts for analysis
  ANALYSIS: ['CONFIRM_DUE', 'MEETING_REQUESTED', 'ON_HOLD', 'REJECTED'], // 2-day countdown, then confirm or meeting
  CONFIRM_DUE: ['DESIGN', 'ON_HOLD', 'REJECTED'], // After confirmation, go to design
  MEETING_REQUESTED: ['CONFIRM_DUE', 'ON_HOLD', 'REJECTED'], // After meeting, confirm due date
  DESIGN: ['DEVELOPMENT', 'ON_HOLD', 'REJECTED'], // Direct to development (removed DIGITAL_APPROVAL)
  DEVELOPMENT: ['TESTING', 'ON_HOLD', 'CANCELLED'], // Development complete, go to testing
  TESTING: ['CUSTOMER_APPROVAL', 'DEVELOPMENT', 'ON_HOLD'], // Testing complete, go to customer approval
  CUSTOMER_APPROVAL: ['DEPLOYMENT', 'TESTING', 'ON_HOLD'], // Customer approves with email attachment
  DEPLOYMENT: ['VERIFICATION', 'ON_HOLD'], // Deployment includes UAT, go directly to verification
  VERIFICATION: ['CLOSED', 'DEPLOYMENT', 'ON_HOLD'], // Verification complete, close ticket
  CLOSED: [],
  ON_HOLD: ['ANALYSIS', 'CONFIRM_DUE', 'DESIGN', 'DEVELOPMENT', 'TESTING', 'CUSTOMER_APPROVAL', 'DEPLOYMENT', 'CANCELLED'],
  REJECTED: [],
  CANCELLED: [],
  
  // Legacy support
  PENDING_REVIEW: ['CATEGORIZED', 'REJECTED'],
  CATEGORIZED: ['PRIORITIZED'],
  PRIORITIZED: ['ANALYSIS'],
  APPROVAL: ['DEVELOPMENT', 'ON_HOLD', 'REJECTED'],
};

ticketsRouter.post('/:id/transition', async (req: Request, res: Response) => {
  const { id } = req.params;
  const parse = transitionSchema.safeParse(req.body ?? {});
  if (!parse.success) return res.status(400).json({ error: 'Invalid payload', details: parse.error.flatten() });
  const { to, dueAt, slaHours, decision, comment, priority, category, userRole } = parse.data;

  const existing = await prisma.ticket.findUnique({ where: { id }, include: { stages: { orderBy: { order: 'asc' } } } });
  if (!existing) return res.status(404).json({ error: 'Not found' });

  // Check role-based permissions - user must be able to perform actions on the target phase
  const userPermissions = rolePermissions[userRole || 'CREATOR'] || [];
  if (!userPermissions.includes(to)) {
    return res.status(403).json({ error: `User role ${userRole} cannot perform actions on ${to} phase` });
  }

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

  // Auto-transition through CATEGORIZED and PRIORITIZED if going to ANALYSIS
  const stagesToCreate = [];
  
  if (to === 'CONFIRM_DUE' && existing.status === 'ANALYSIS') {
    // Create CONFIRM_DUE stage with SLA calculation
    stagesToCreate.push({
      name: 'Confirm Due Date',
      key: 'CONFIRM_DUE',
      order: nextOrder,
      startedAt: now,
      dueAt: dueAt ? new Date(dueAt) : null,
      slaHours: typeof slaHours === 'number' ? slaHours : (computedSla ?? null),
      decision: decision ?? null,
      comment: comment ?? null,
    });
  } else if (to === 'ANALYSIS' && existing.status === 'SUBMITTED') {
    // Create CATEGORIZED stage (automatic)
    stagesToCreate.push({
      name: 'Categorized',
      key: 'CATEGORIZED',
      order: nextOrder,
      startedAt: now,
      comment: 'Automatically categorized based on request content',
    });
    
    // Create PRIORITIZED stage (automatic)
    stagesToCreate.push({
      name: 'Prioritized',
      key: 'PRIORITIZED',
      order: nextOrder + 1,
      startedAt: now,
      comment: 'Priority confirmed with requester during acceptance',
    });
    
    // Create ANALYSIS stage (main transition)
    stagesToCreate.push({
      name: 'Analysis',
      key: 'ANALYSIS',
      order: nextOrder + 2,
      startedAt: now,
      dueAt: dueAt ? new Date(dueAt) : null,
      slaHours: typeof slaHours === 'number' ? slaHours : (computedSla ?? null),
      decision: decision ?? null,
      comment: comment ?? null,
    });
  } else {
    // Normal single stage creation
    stagesToCreate.push({
      name: to.replace(/_/g, ' ').toLowerCase().replace(/\b\w/g, c => c.toUpperCase()),
      key: to,
      order: nextOrder,
      startedAt: now,
      dueAt: dueAt ? new Date(dueAt) : null,
      slaHours: typeof slaHours === 'number' ? slaHours : (computedSla ?? null),
      decision: decision ?? null,
      comment: comment ?? null,
    });
  }

  // Mark previous stages as completed
  const currentStage = existing.stages.find(stage => stage.key === existing.status);
  const stagesToUpdate = [];
  if (currentStage && !currentStage.completedAt) {
    stagesToUpdate.push({
      where: { id: currentStage.id },
      data: { completedAt: now }
    });
  }

  const updated = await prisma.ticket.update({
    where: { id },
    data: {
      status: to,
      stages: {
        create: stagesToCreate,
        update: stagesToUpdate,
      },
      // Update priority and category if provided
      ...(priority ? { priority } : {}),
      ...(category ? { category } : {}),
      // Set SLA hours for any stage that provides it
      ...((computedSla ?? null) || typeof slaHours === 'number'
        ? { totalSlaHours: (computedSla ?? (slaHours as number)) }
        : {}),
    },
    include: { stages: { orderBy: { order: 'asc' } } },
  });

  return res.json(updated);
});

// POST /tickets/:id/assign - Assign ticket to user/team
const assignSchema = z.object({
  assignedToId: z.string().optional(),
  teamMembers: z.array(z.string()).optional(),
  comment: z.string().max(2000).optional(),
});

ticketsRouter.post('/:id/assign', async (req: Request, res: Response) => {
  const { id } = req.params;
  const parse = assignSchema.safeParse(req.body ?? {});
  
  if (!parse.success) {
    return res.status(400).json({ error: 'Invalid payload', details: parse.error.flatten() });
  }

  const { assignedToId, teamMembers, comment } = parse.data;

  try {
    // Verify assigned user exists if provided
    if (assignedToId) {
      const user = await prisma.user.findUnique({ where: { id: assignedToId } });
      if (!user) {
        return res.status(404).json({ error: 'Assigned user not found' });
      }
    }

    // Verify team members exist if provided
    if (teamMembers && teamMembers.length > 0) {
      const users = await prisma.user.findMany({ where: { id: { in: teamMembers } } });
      if (users.length !== teamMembers.length) {
        return res.status(404).json({ error: 'One or more team members not found' });
      }
    }

    const updated = await prisma.ticket.update({
      where: { id },
      data: {
        assignedToId: assignedToId || null,
        teamMembers: teamMembers ? JSON.stringify(teamMembers) : null,
        stages: {
          create: {
            name: 'Assignment',
            key: 'ASSIGNMENT',
            order: 999, // High order to appear at end
            startedAt: new Date(),
            comment: comment || null,
            assignee: assignedToId || null,
          }
        }
      },
      include: { 
        stages: { orderBy: { order: 'asc' } },
        assignedTo: {
          select: { id: true, name: true, email: true, role: true }
        }
      }
    });

    res.json(updated);
  } catch (error) {
    console.error('Error assigning ticket:', error);
    res.status(500).json({ error: 'Failed to assign ticket' });
  }
});

// GET /tickets/assigned/:userId - Get tickets assigned to specific user
ticketsRouter.get('/assigned/:userId', async (req: Request, res: Response) => {
  const { userId } = req.params;
  const { status, page = '1', limit = '10' } = req.query;

  try {
    const pageNum = parseInt(page as string);
    const limitNum = parseInt(limit as string);
    const skip = (pageNum - 1) * limitNum;

    const where: any = {
      OR: [
        { assignedToId: userId },
        { teamMembers: { contains: userId } }
      ]
    };

    if (status) {
      where.status = status;
    }

    const [tickets, total] = await Promise.all([
      prisma.ticket.findMany({
        where,
        skip,
        take: limitNum,
        orderBy: { updatedAt: 'desc' },
        include: {
          assignedTo: {
            select: { id: true, name: true, email: true, role: true }
          }
        }
      }),
      prisma.ticket.count({ where })
    ]);

    res.json({
      tickets,
      pagination: {
        page: pageNum,
        limit: limitNum,
        total,
        pages: Math.ceil(total / limitNum)
      }
    });
  } catch (error) {
    console.error('Error fetching assigned tickets:', error);
    res.status(500).json({ error: 'Failed to fetch assigned tickets' });
  }
});

// GET /tickets/sla-performance - Get SLA performance metrics
ticketsRouter.get('/sla-performance', async (_req: Request, res: Response) => {
  try {
    const performance = await getSLAPerformance();
    return res.json(performance);
  } catch (error) {
    return res.status(500).json({ error: 'Failed to get SLA performance metrics' });
  }
});

// GET /tickets/:id/mttr - Get MTTR for specific ticket
ticketsRouter.get('/:id/mttr', async (req: Request, res: Response) => {
  const { id } = req.params;
  
  try {
    const mttr = await calculateMTTR(id);
    return res.json(mttr);
  } catch (error) {
    return res.status(404).json({ error: 'Ticket not found or MTTR calculation failed' });
  }
});
