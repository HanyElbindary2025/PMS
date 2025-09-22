import { EventEmitter } from 'node:events';

export type TicketEvent =
	| { type: 'ticket.created'; payload: { id: string; status: string } }
	| { type: 'ticket.updated'; payload: { id: string; status?: string } }
	| { type: 'sla.tick'; payload: { id: string; remainingMs: number } };

class TypedEmitter extends EventEmitter {}

export const bus = new TypedEmitter();


