// Professional ITSM Workflow Configuration
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

export const WORKFLOW_PHASES: Record<string, WorkflowPhase> = {
  SUBMITTED: {
    key: 'SUBMITTED',
    name: 'Submitted',
    description: 'Initial request received and awaiting categorization',
    slaHours: 2,
    requiredFields: ['title', 'description', 'requesterEmail'],
    optionalFields: ['priority', 'impact', 'urgency', 'businessJustification'],
    allowedTransitions: ['CATEGORIZED', 'REJECTED'],
    requiresApproval: false,
    attachmentCategories: ['Initial Requirements', 'Screenshots', 'Documents']
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
    attachmentCategories: ['Categorization Rationale', 'Service Documentation']
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
    attachmentCategories: ['Impact Analysis', 'Risk Assessment', 'Business Case']
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
    attachmentCategories: ['Technical Documentation', 'Analysis Reports', 'Feasibility Study']
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
    attachmentCategories: ['Design Documents', 'Architecture Diagrams', 'Mockups', 'Wireframes']
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
    attachmentCategories: ['Approval Documents', 'Sign-offs', 'Stakeholder Feedback']
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
    attachmentCategories: ['Code', 'Test Cases', 'Progress Reports', 'Documentation']
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
    attachmentCategories: ['Test Reports', 'Bug Reports', 'Test Data', 'Performance Reports']
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
    attachmentCategories: ['UAT Reports', 'User Feedback', 'Sign-offs', 'Acceptance Criteria']
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
    attachmentCategories: ['Deployment Scripts', 'Monitoring Reports', 'Go-Live Checklist']
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
    attachmentCategories: ['Verification Reports', 'Monitoring Data', 'Performance Metrics']
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
    attachmentCategories: ['Final Reports', 'Documentation', 'Lessons Learned']
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
    attachmentCategories: ['Hold Justification', 'Dependency Documentation', 'Issue Reports']
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
    attachmentCategories: ['Rejection Documentation', 'Alternatives', 'Appeal Process']
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
    attachmentCategories: ['Cancellation Documentation', 'Impact Assessment']
  }
};

export const WORKFLOW_TRANSITIONS: Record<string, string[]> = {
  SUBMITTED: ['CATEGORIZED', 'REJECTED'],
  CATEGORIZED: ['PRIORITIZED', 'REJECTED'],
  PRIORITIZED: ['ANALYSIS', 'REJECTED'],
  ANALYSIS: ['DESIGN', 'ON_HOLD', 'REJECTED'],
  DESIGN: ['APPROVAL', 'ON_HOLD', 'REJECTED'],
  APPROVAL: ['DEVELOPMENT', 'ON_HOLD', 'REJECTED'],
  DEVELOPMENT: ['TESTING', 'ON_HOLD', 'CANCELLED'],
  TESTING: ['UAT', 'DEVELOPMENT', 'ON_HOLD'],
  UAT: ['DEPLOYMENT', 'TESTING', 'ON_HOLD'],
  DEPLOYMENT: ['VERIFICATION', 'ON_HOLD'],
  VERIFICATION: ['CLOSED', 'DEPLOYMENT', 'ON_HOLD'],
  ON_HOLD: ['ANALYSIS', 'DESIGN', 'DEVELOPMENT', 'TESTING', 'UAT', 'DEPLOYMENT', 'CANCELLED'],
  REJECTED: [],
  CANCELLED: [],
  CLOSED: []
};

export function getWorkflowPhase(key: string): WorkflowPhase | undefined {
  return WORKFLOW_PHASES[key];
}

export function getAllowedTransitions(currentPhase: string): string[] {
  return WORKFLOW_TRANSITIONS[currentPhase] || [];
}

export function isTransitionAllowed(from: string, to: string): boolean {
  return getAllowedTransitions(from).includes(to);
}

export function getPhaseSLA(phase: string): number {
  return WORKFLOW_PHASES[phase]?.slaHours || 24;
}

export function requiresApproval(phase: string): boolean {
  return WORKFLOW_PHASES[phase]?.requiresApproval || false;
}
