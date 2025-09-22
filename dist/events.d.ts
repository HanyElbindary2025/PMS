import { EventEmitter } from 'node:events';
export type TicketEvent = {
    type: 'ticket.created';
    payload: {
        id: string;
        status: string;
    };
} | {
    type: 'ticket.updated';
    payload: {
        id: string;
        status?: string;
    };
} | {
    type: 'sla.tick';
    payload: {
        id: string;
        remainingMs: number;
    };
};
declare class TypedEmitter extends EventEmitter {
}
export declare const bus: TypedEmitter;
export {};
//# sourceMappingURL=events.d.ts.map