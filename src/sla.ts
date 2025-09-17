import { PrismaClient } from '@prisma/client';
import { bus } from './events.js';

const prisma = new PrismaClient();

// naive in-memory ticker: recomputes remaining SLA every 30s and emits sse events
export function startSlaTicker(): void {
	setInterval(async () => {
		// For demo: consider tickets with totalSlaHours set
		const tickets = await prisma.ticket.findMany({
			where: { totalSlaHours: { not: null } },
			select: { id: true, totalSlaHours: true, createdAt: true },
		});
		const now = Date.now();
		for (const t of tickets) {
			const deadline = new Date(t.createdAt).getTime() + (t.totalSlaHours! * 60 * 60 * 1000);
			const remainingMs = Math.max(0, deadline - now);
			bus.emit('event', { type: 'sla.tick', payload: { id: t.id, remainingMs } });
		}
	}, 30000);
}


