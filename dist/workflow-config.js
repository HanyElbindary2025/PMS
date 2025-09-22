// Professional ITSM Workflow Configuration
// Based on industry standards (ITIL, COBIT, ISO 20000)
export const PROFESSIONAL_WORKFLOW = {
    SUBMITTED: {
        key: 'SUBMITTED',
        name: 'Submitted',
        description: 'Initial request received and awaiting categorization',
        slaHours: 2,
        requiredFields: ['title', 'description', 'requesterEmail'],
        optionalFields: ['priority', 'impact', 'urgency', 'businessJustification'],
        allowedTransitions: ['CATEGORIZED', 'REJECTED'],
        requiresApproval: false,
        attachmentCategories: ['Initial Requirements', 'Screenshots', 'Documents'],
        color: '#9E9E9E',
        icon: '📝',
        assigneeRole: 'SERVICE_DESK',
        autoAssign: true
    },
    CATEGORIZED: {
        key: 'CATEGORIZED',
        name: 'Categorized',
        description: 'Request properly classified and assigned to service category',
        slaHours: 4,
        requiredFields: ['category', 'subcategory', 'service'],
        optionalFields: ['priority', 'impact', 'urgency'],
        allowedTransitions: ['PRIORITIZED', 'REJECTED'],
        requiresApproval: false,
        attachmentCategories: ['Categorization Rationale', 'Service Documentation'],
        color: '#FF9800',
        icon: '🏷️',
        assigneeRole: 'SERVICE_DESK',
        autoAssign: true
    },
    PRIORITIZED: {
        key: 'PRIORITIZED',
        name: 'Prioritized',
        description: 'Business impact assessed and priority assigned',
        slaHours: 8,
        requiredFields: ['priority', 'impact', 'urgency', 'businessValue'],
        optionalFields: ['riskAssessment', 'resourceRequirements'],
        allowedTransitions: ['ANALYSIS', 'REJECTED'],
        requiresApproval: false,
        attachmentCategories: ['Impact Analysis', 'Risk Assessment', 'Business Case'],
        color: '#FF5722',
        icon: '⚡',
        assigneeRole: 'SERVICE_MANAGER',
        autoAssign: true
    },
    ANALYSIS: {
        key: 'ANALYSIS',
        name: 'Analysis',
        description: 'Technical analysis and feasibility assessment',
        slaHours: 24,
        requiredFields: ['technicalAnalysis', 'dependencies'],
        optionalFields: ['effortEstimate', 'architecture', 'riskAssessment'],
        allowedTransitions: ['DESIGN', 'ON_HOLD', 'REJECTED'],
        requiresApproval: false,
        attachmentCategories: ['Technical Documentation', 'Analysis Reports', 'Feasibility Study'],
        color: '#FFC107',
        icon: '🔍',
        assigneeRole: 'TECHNICAL_ANALYST',
        autoAssign: true
    },
    DESIGN: {
        key: 'DESIGN',
        name: 'Design',
        description: 'Solution design and architecture planning',
        slaHours: 48,
        requiredFields: ['architecture', 'implementationPlan'],
        optionalFields: ['dependencies', 'effortEstimate', 'qualityGates'],
        allowedTransitions: ['APPROVAL', 'ON_HOLD', 'REJECTED'],
        requiresApproval: false,
        attachmentCategories: ['Design Documents', 'Architecture Diagrams', 'Mockups', 'Wireframes'],
        color: '#2196F3',
        icon: '🎨',
        assigneeRole: 'SOLUTION_ARCHITECT',
        autoAssign: true
    },
    APPROVAL: {
        key: 'APPROVAL',
        name: 'Approval',
        description: 'Design approval by stakeholders and management',
        slaHours: 24,
        requiredFields: ['approvalStatus', 'approver'],
        optionalFields: ['approvalComments', 'conditions'],
        allowedTransitions: ['DEVELOPMENT', 'ON_HOLD', 'REJECTED'],
        requiresApproval: true,
        attachmentCategories: ['Approval Documents', 'Sign-offs', 'Stakeholder Feedback'],
        color: '#9C27B0',
        icon: '✅',
        assigneeRole: 'MANAGER',
        autoAssign: false
    },
    DEVELOPMENT: {
        key: 'DEVELOPMENT',
        name: 'Development',
        description: 'Implementation and coding phase',
        slaHours: 168, // 1 week default, can be overridden
        requiredFields: ['progressPercentage'],
        optionalFields: ['codeRepository', 'testingPlan', 'blockers'],
        allowedTransitions: ['TESTING', 'ON_HOLD', 'CANCELLED'],
        requiresApproval: false,
        attachmentCategories: ['Code', 'Test Cases', 'Progress Reports', 'Documentation'],
        color: '#4CAF50',
        icon: '💻',
        assigneeRole: 'DEVELOPER',
        autoAssign: true
    },
    TESTING: {
        key: 'TESTING',
        name: 'Testing',
        description: 'Quality assurance and testing phase',
        slaHours: 24,
        requiredFields: ['testResults', 'testCoverage'],
        optionalFields: ['defectsFound', 'performanceMetrics'],
        allowedTransitions: ['UAT', 'DEVELOPMENT', 'ON_HOLD'],
        requiresApproval: false,
        attachmentCategories: ['Test Reports', 'Bug Reports', 'Test Data', 'Performance Reports'],
        color: '#FF9800',
        icon: '🧪',
        assigneeRole: 'QA_ENGINEER',
        autoAssign: true
    },
    UAT: {
        key: 'UAT',
        name: 'User Acceptance Testing',
        description: 'User acceptance testing and feedback collection',
        slaHours: 48,
        requiredFields: ['uatResults', 'userFeedback'],
        optionalFields: ['acceptanceCriteria', 'customerSatisfaction'],
        allowedTransitions: ['DEPLOYMENT', 'TESTING', 'ON_HOLD'],
        requiresApproval: false,
        attachmentCategories: ['UAT Reports', 'User Feedback', 'Sign-offs', 'Acceptance Criteria'],
        color: '#795548',
        icon: '👥',
        assigneeRole: 'BUSINESS_ANALYST',
        autoAssign: true
    },
    DEPLOYMENT: {
        key: 'DEPLOYMENT',
        name: 'Deployment',
        description: 'Production deployment and go-live',
        slaHours: 4,
        requiredFields: ['deploymentPlan', 'goLiveDate'],
        optionalFields: ['rollbackPlan', 'monitoringPlan'],
        allowedTransitions: ['VERIFICATION', 'ON_HOLD'],
        requiresApproval: false,
        attachmentCategories: ['Deployment Scripts', 'Monitoring Reports', 'Go-Live Checklist'],
        color: '#607D8B',
        icon: '🚀',
        assigneeRole: 'DEVOPS_ENGINEER',
        autoAssign: true
    },
    VERIFICATION: {
        key: 'VERIFICATION',
        name: 'Verification',
        description: 'Post-deployment verification and validation',
        slaHours: 8,
        requiredFields: ['verificationResults', 'performanceMetrics'],
        optionalFields: ['issuesFound', 'customerSatisfaction'],
        allowedTransitions: ['CLOSED', 'DEPLOYMENT', 'ON_HOLD'],
        requiresApproval: false,
        attachmentCategories: ['Verification Reports', 'Monitoring Data', 'Performance Metrics'],
        color: '#3F51B5',
        icon: '🔍',
        assigneeRole: 'OPERATIONS_ENGINEER',
        autoAssign: true
    },
    CLOSED: {
        key: 'CLOSED',
        name: 'Closed',
        description: 'Request completed and closed',
        slaHours: 24,
        requiredFields: ['closureReason'],
        optionalFields: ['lessonsLearned', 'customerSatisfaction'],
        allowedTransitions: [],
        requiresApproval: false,
        attachmentCategories: ['Final Reports', 'Documentation', 'Lessons Learned'],
        color: '#4CAF50',
        icon: '✅',
        assigneeRole: 'SERVICE_MANAGER',
        autoAssign: true
    },
    ON_HOLD: {
        key: 'ON_HOLD',
        name: 'On Hold',
        description: 'Request paused due to dependencies or issues',
        slaHours: 0,
        requiredFields: ['holdReason', 'expectedResolutionDate'],
        optionalFields: ['dependencies', 'blockers'],
        allowedTransitions: ['ANALYSIS', 'DESIGN', 'DEVELOPMENT', 'TESTING', 'UAT', 'DEPLOYMENT', 'CANCELLED'],
        requiresApproval: false,
        attachmentCategories: ['Hold Justification', 'Dependency Documentation', 'Issue Reports'],
        color: '#FFC107',
        icon: '⏸️',
        assigneeRole: 'SERVICE_MANAGER',
        autoAssign: true
    },
    REJECTED: {
        key: 'REJECTED',
        name: 'Rejected',
        description: 'Request rejected with justification',
        slaHours: 24,
        requiredFields: ['rejectionReason'],
        optionalFields: ['alternativeSolutions', 'appealProcess'],
        allowedTransitions: [],
        requiresApproval: false,
        attachmentCategories: ['Rejection Documentation', 'Alternatives', 'Appeal Process'],
        color: '#F44336',
        icon: '❌',
        assigneeRole: 'SERVICE_MANAGER',
        autoAssign: true
    },
    CANCELLED: {
        key: 'CANCELLED',
        name: 'Cancelled',
        description: 'Request cancelled by requester or system',
        slaHours: 4,
        requiredFields: ['cancellationReason'],
        optionalFields: ['impactAssessment', 'resourceRelease'],
        allowedTransitions: [],
        requiresApproval: false,
        attachmentCategories: ['Cancellation Documentation', 'Impact Assessment'],
        color: '#9E9E9E',
        icon: '🚫',
        assigneeRole: 'SERVICE_MANAGER',
        autoAssign: true
    }
};
// User Roles and Permissions
export const USER_ROLES = {
    ADMIN: {
        name: 'Administrator',
        permissions: ['ALL'],
        color: '#E91E63'
    },
    SERVICE_MANAGER: {
        name: 'Service Manager',
        permissions: ['MANAGE_TICKETS', 'APPROVE_REQUESTS', 'VIEW_REPORTS', 'MANAGE_USERS'],
        color: '#9C27B0'
    },
    SERVICE_DESK: {
        name: 'Service Desk',
        permissions: ['CREATE_TICKETS', 'UPDATE_TICKETS', 'VIEW_TICKETS', 'ASSIGN_TICKETS'],
        color: '#2196F3'
    },
    TECHNICAL_ANALYST: {
        name: 'Technical Analyst',
        permissions: ['ANALYZE_TICKETS', 'UPDATE_TICKETS', 'VIEW_TICKETS'],
        color: '#FF9800'
    },
    SOLUTION_ARCHITECT: {
        name: 'Solution Architect',
        permissions: ['DESIGN_SOLUTIONS', 'UPDATE_TICKETS', 'VIEW_TICKETS'],
        color: '#4CAF50'
    },
    DEVELOPER: {
        name: 'Developer',
        permissions: ['DEVELOP_SOLUTIONS', 'UPDATE_TICKETS', 'VIEW_TICKETS'],
        color: '#00BCD4'
    },
    QA_ENGINEER: {
        name: 'QA Engineer',
        permissions: ['TEST_SOLUTIONS', 'UPDATE_TICKETS', 'VIEW_TICKETS'],
        color: '#FF5722'
    },
    BUSINESS_ANALYST: {
        name: 'Business Analyst',
        permissions: ['ANALYZE_REQUIREMENTS', 'UPDATE_TICKETS', 'VIEW_TICKETS'],
        color: '#795548'
    },
    DEVOPS_ENGINEER: {
        name: 'DevOps Engineer',
        permissions: ['DEPLOY_SOLUTIONS', 'UPDATE_TICKETS', 'VIEW_TICKETS'],
        color: '#607D8B'
    },
    OPERATIONS_ENGINEER: {
        name: 'Operations Engineer',
        permissions: ['MONITOR_SYSTEMS', 'UPDATE_TICKETS', 'VIEW_TICKETS'],
        color: '#3F51B5'
    },
    MANAGER: {
        name: 'Manager',
        permissions: ['APPROVE_REQUESTS', 'VIEW_REPORTS', 'VIEW_TICKETS'],
        color: '#9E9E9E'
    },
    CREATOR: {
        name: 'Request Creator',
        permissions: ['CREATE_TICKETS', 'VIEW_OWN_TICKETS'],
        color: '#757575'
    }
};
// SLA Configuration
export const SLA_CONFIG = {
    CRITICAL: { hours: 2, color: '#F44336', name: 'Critical' },
    HIGH: { hours: 8, color: '#FF9800', name: 'High' },
    MEDIUM: { hours: 24, color: '#FFC107', name: 'Medium' },
    LOW: { hours: 72, color: '#4CAF50', name: 'Low' }
};
// Priority Matrix
export const PRIORITY_MATRIX = {
    'HIGH-HIGH': 'CRITICAL',
    'HIGH-MEDIUM': 'HIGH',
    'HIGH-LOW': 'HIGH',
    'MEDIUM-HIGH': 'HIGH',
    'MEDIUM-MEDIUM': 'MEDIUM',
    'MEDIUM-LOW': 'MEDIUM',
    'LOW-HIGH': 'MEDIUM',
    'LOW-MEDIUM': 'LOW',
    'LOW-LOW': 'LOW'
};
export function getWorkflowPhase(key) {
    return PROFESSIONAL_WORKFLOW[key];
}
export function getAllowedTransitions(currentPhase) {
    return PROFESSIONAL_WORKFLOW[currentPhase]?.allowedTransitions || [];
}
export function isTransitionAllowed(from, to) {
    return getAllowedTransitions(from).includes(to);
}
export function getPhaseSLA(phase) {
    return PROFESSIONAL_WORKFLOW[phase]?.slaHours || 24;
}
export function requiresApproval(phase) {
    return PROFESSIONAL_WORKFLOW[phase]?.requiresApproval || false;
}
export function getPhaseColor(phase) {
    return PROFESSIONAL_WORKFLOW[phase]?.color || '#9E9E9E';
}
export function getPhaseIcon(phase) {
    return PROFESSIONAL_WORKFLOW[phase]?.icon || '📋';
}
export function calculatePriority(impact, urgency) {
    const key = `${impact}-${urgency}`;
    return PRIORITY_MATRIX[key] || 'MEDIUM';
}
export function getSLAConfig(priority) {
    return SLA_CONFIG[priority] || SLA_CONFIG.MEDIUM;
}
//# sourceMappingURL=workflow-config.js.map