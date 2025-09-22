import { PrismaClient } from '@prisma/client';
import { bus } from './events.js';
const prisma = new PrismaClient();
// Enhanced SLA tracking with proper start times and MTTR calculation
export function startSlaTicker() {
    setInterval(async () => {
        // Get tickets that are in progress (SLA should be running)
        const tickets = await prisma.ticket.findMany({
            where: {
                status: {
                    notIn: ['CLOSED', 'REJECTED', 'CANCELLED']
                },
                totalSlaHours: { not: null }
            },
            select: {
                id: true,
                ticketNumber: true,
                title: true,
                totalSlaHours: true,
                createdAt: true,
                status: true,
                priority: true,
                // Get SLA start time from stages
                stages: {
                    where: { key: 'ANALYSIS' }, // SLA starts when analysis begins
                    select: { startedAt: true },
                    orderBy: { startedAt: 'asc' },
                    take: 1
                }
            },
        });
        const now = Date.now();
        for (const ticket of tickets) {
            // SLA starts from ANALYSIS phase, not from creation
            const slaStartTime = ticket.stages.length > 0
                ? new Date(ticket.stages[0].startedAt).getTime()
                : new Date(ticket.createdAt).getTime(); // Fallback to creation time
            const deadline = slaStartTime + (ticket.totalSlaHours * 60 * 60 * 1000);
            const remainingMs = Math.max(0, deadline - now);
            const isOverdue = now > deadline;
            // Calculate MTTR (Mean Time To Resolution) - time from creation to current
            const mttrMs = now - new Date(ticket.createdAt).getTime();
            const mttrHours = mttrMs / (1000 * 60 * 60);
            // Emit SLA update event
            bus.emit('event', {
                type: 'sla.tick',
                payload: {
                    id: ticket.id,
                    ticketNumber: ticket.ticketNumber,
                    title: ticket.title,
                    status: ticket.status,
                    priority: ticket.priority,
                    remainingMs,
                    remainingHours: remainingMs / (1000 * 60 * 60),
                    isOverdue,
                    mttrHours,
                    slaStartTime: new Date(slaStartTime).toISOString(),
                    deadline: new Date(deadline).toISOString()
                }
            });
            // If SLA is breached, update ticket status
            if (isOverdue && ticket.status !== 'ON_HOLD') {
                await prisma.ticket.update({
                    where: { id: ticket.id },
                    data: {
                        slaBreachRisk: 'HIGH',
                        // Add a stage to track SLA breach
                        stages: {
                            create: {
                                name: 'SLA Breach Alert',
                                key: 'SLA_BREACH',
                                order: 999,
                                startedAt: new Date(),
                                comment: `SLA breached by ${Math.abs(remainingMs / (1000 * 60 * 60)).toFixed(1)} hours`
                            }
                        }
                    }
                });
            }
        }
    }, 30000); // Check every 30 seconds
}
// Calculate MTTR for a specific ticket
export async function calculateMTTR(ticketId) {
    const ticket = await prisma.ticket.findUnique({
        where: { id: ticketId },
        select: {
            createdAt: true,
            status: true,
            stages: {
                where: { key: 'CLOSED' },
                select: { completedAt: true },
                orderBy: { completedAt: 'desc' },
                take: 1
            }
        }
    });
    if (!ticket) {
        throw new Error('Ticket not found');
    }
    const isResolved = ticket.status === 'CLOSED';
    const closedAt = ticket.stages.length > 0 ? ticket.stages[0].completedAt : null;
    const mttrHours = closedAt
        ? (new Date(closedAt).getTime() - new Date(ticket.createdAt).getTime()) / (1000 * 60 * 60)
        : undefined;
    return {
        createdAt: ticket.createdAt,
        closedAt: closedAt || undefined,
        mttrHours,
        isResolved
    };
}
// Get SLA performance metrics
export async function getSLAPerformance() {
    const tickets = await prisma.ticket.findMany({
        where: { status: 'CLOSED' },
        select: {
            createdAt: true,
            totalSlaHours: true,
            stages: {
                where: { key: 'CLOSED' },
                select: { completedAt: true },
                orderBy: { completedAt: 'desc' },
                take: 1
            }
        }
    });
    let totalTickets = tickets.length;
    let onTimeTickets = 0;
    let totalMTTR = 0;
    for (const ticket of tickets) {
        if (ticket.stages.length > 0 && ticket.totalSlaHours) {
            const closedAt = new Date(ticket.stages[0].completedAt);
            const createdAt = new Date(ticket.createdAt);
            const mttrHours = (closedAt.getTime() - createdAt.getTime()) / (1000 * 60 * 60);
            totalMTTR += mttrHours;
            // Check if resolved within SLA
            if (mttrHours <= ticket.totalSlaHours) {
                onTimeTickets++;
            }
        }
    }
    const overdueTickets = totalTickets - onTimeTickets;
    const averageMTTR = totalTickets > 0 ? totalMTTR / totalTickets : 0;
    const slaCompliance = totalTickets > 0 ? (onTimeTickets / totalTickets) * 100 : 0;
    return {
        totalTickets,
        onTimeTickets,
        overdueTickets,
        averageMTTR,
        slaCompliance
    };
}
//# sourceMappingURL=sla.js.map