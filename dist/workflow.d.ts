export interface WorkflowPhase {
    key: string;
    name: string;
    description: string;
    slaHours: number;
    requiredFields: string[];
    optionalFields: string[];
    allowedTransitions: string[];
    requiresApproval: boolean;
    attachmentCategories: string[];
}
export declare const WORKFLOW_PHASES: Record<string, WorkflowPhase>;
export declare const WORKFLOW_TRANSITIONS: Record<string, string[]>;
export declare function getWorkflowPhase(key: string): WorkflowPhase | undefined;
export declare function getAllowedTransitions(currentPhase: string): string[];
export declare function isTransitionAllowed(from: string, to: string): boolean;
export declare function getPhaseSLA(phase: string): number;
export declare function requiresApproval(phase: string): boolean;
//# sourceMappingURL=workflow.d.ts.map