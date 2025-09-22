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
    color: string;
    icon: string;
    assigneeRole?: string;
    autoAssign?: boolean;
}
export declare const PROFESSIONAL_WORKFLOW: Record<string, WorkflowPhase>;
export declare const USER_ROLES: {
    ADMIN: {
        name: string;
        permissions: string[];
        color: string;
    };
    SERVICE_MANAGER: {
        name: string;
        permissions: string[];
        color: string;
    };
    SERVICE_DESK: {
        name: string;
        permissions: string[];
        color: string;
    };
    TECHNICAL_ANALYST: {
        name: string;
        permissions: string[];
        color: string;
    };
    SOLUTION_ARCHITECT: {
        name: string;
        permissions: string[];
        color: string;
    };
    DEVELOPER: {
        name: string;
        permissions: string[];
        color: string;
    };
    QA_ENGINEER: {
        name: string;
        permissions: string[];
        color: string;
    };
    BUSINESS_ANALYST: {
        name: string;
        permissions: string[];
        color: string;
    };
    DEVOPS_ENGINEER: {
        name: string;
        permissions: string[];
        color: string;
    };
    OPERATIONS_ENGINEER: {
        name: string;
        permissions: string[];
        color: string;
    };
    MANAGER: {
        name: string;
        permissions: string[];
        color: string;
    };
    CREATOR: {
        name: string;
        permissions: string[];
        color: string;
    };
};
export declare const SLA_CONFIG: {
    CRITICAL: {
        hours: number;
        color: string;
        name: string;
    };
    HIGH: {
        hours: number;
        color: string;
        name: string;
    };
    MEDIUM: {
        hours: number;
        color: string;
        name: string;
    };
    LOW: {
        hours: number;
        color: string;
        name: string;
    };
};
export declare const PRIORITY_MATRIX: {
    'HIGH-HIGH': string;
    'HIGH-MEDIUM': string;
    'HIGH-LOW': string;
    'MEDIUM-HIGH': string;
    'MEDIUM-MEDIUM': string;
    'MEDIUM-LOW': string;
    'LOW-HIGH': string;
    'LOW-MEDIUM': string;
    'LOW-LOW': string;
};
export declare function getWorkflowPhase(key: string): WorkflowPhase | undefined;
export declare function getAllowedTransitions(currentPhase: string): string[];
export declare function isTransitionAllowed(from: string, to: string): boolean;
export declare function getPhaseSLA(phase: string): number;
export declare function requiresApproval(phase: string): boolean;
export declare function getPhaseColor(phase: string): string;
export declare function getPhaseIcon(phase: string): string;
export declare function calculatePriority(impact: string, urgency: string): string;
export declare function getSLAConfig(priority: string): {
    hours: number;
    color: string;
    name: string;
} | {
    hours: number;
    color: string;
    name: string;
} | {
    hours: number;
    color: string;
    name: string;
} | {
    hours: number;
    color: string;
    name: string;
};
//# sourceMappingURL=workflow-config.d.ts.map