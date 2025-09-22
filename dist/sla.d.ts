export declare function startSlaTicker(): void;
export declare function calculateMTTR(ticketId: string): Promise<{
    createdAt: Date;
    closedAt?: Date;
    mttrHours?: number;
    isResolved: boolean;
}>;
export declare function getSLAPerformance(): Promise<{
    totalTickets: number;
    onTimeTickets: number;
    overdueTickets: number;
    averageMTTR: number;
    slaCompliance: number;
}>;
//# sourceMappingURL=sla.d.ts.map