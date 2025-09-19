# PMS Database Tables and Workflow Design

## 📊 Database Tables

### 1. **Lookup Table**
**Purpose**: Store dropdown options and configuration data
```sql
CREATE TABLE Lookup (
  id        TEXT PRIMARY KEY,
  type      TEXT NOT NULL,        -- PROJECT, PLATFORM, CATEGORY, PRIORITY
  value     TEXT NOT NULL,        -- The actual option value
  order     INTEGER DEFAULT 0,    -- Display order
  active    BOOLEAN DEFAULT true, -- Enable/disable option
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

### 2. **User Table**
**Purpose**: Store user information and roles
```sql
CREATE TABLE User (
  id          TEXT PRIMARY KEY,
  email       TEXT UNIQUE NOT NULL,
  name        TEXT NOT NULL,
  role        TEXT NOT NULL,      -- ADMIN, SERVICE_MANAGER, DEVELOPER, etc.
  department  TEXT,
  phone       TEXT,
  isActive    BOOLEAN DEFAULT true,
  lastLoginAt DATETIME,
  createdAt   DATETIME DEFAULT CURRENT_TIMESTAMP,
  updatedAt   DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

### 3. **Ticket Table** (Main Entity)
**Purpose**: Store all ticket information and ITSM data
```sql
CREATE TABLE Ticket (
  id              TEXT PRIMARY KEY,
  ticketNumber    TEXT UNIQUE NOT NULL,  -- PDS-yyyy-m-dd-0000000
  title           TEXT NOT NULL,
  description     TEXT NOT NULL,
  requesterEmail  TEXT NOT NULL,
  requesterName   TEXT,
  status          TEXT DEFAULT 'SUBMITTED',
  totalSlaHours   INTEGER,
  details         TEXT,                  -- JSON string for additional data
  
  -- ITSM Fields
  priority        TEXT,                  -- HIGH, MEDIUM, LOW
  impact          TEXT,                  -- HIGH, MEDIUM, LOW
  urgency         TEXT,                  -- HIGH, MEDIUM, LOW
  category        TEXT,                  -- INCIDENT, REQUEST, CHANGE, PROBLEM
  subcategory     TEXT,
  service         TEXT,
  businessJustification TEXT,
  businessValue   TEXT,
  riskAssessment  TEXT,
  technicalAnalysis TEXT,
  dependencies    TEXT,
  effortEstimate  TEXT,
  architecture    TEXT,
  currentPhase    TEXT,
  progressPercentage INTEGER DEFAULT 0,
  blockers        TEXT,
  slaBreachRisk   TEXT,                  -- LOW, MEDIUM, HIGH
  qualityGates    TEXT,
  acceptanceCriteria TEXT,
  testResults     TEXT,
  closureReason   TEXT,
  lessonsLearned  TEXT,
  customerSatisfaction TEXT,
  
  -- Team Assignment
  assignedToId    TEXT,                  -- Current assignee
  createdById     TEXT,                  -- Who created the ticket
  teamMembers     TEXT,                  -- JSON array of team member IDs
  escalationLevel INTEGER DEFAULT 0,     -- 0=normal, 1=escalated, 2=critical
  
  createdAt       DATETIME DEFAULT CURRENT_TIMESTAMP,
  updatedAt       DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (assignedToId) REFERENCES User(id),
  FOREIGN KEY (createdById) REFERENCES User(id)
);
```

### 4. **Stage Table**
**Purpose**: Track workflow progression and phase history
```sql
CREATE TABLE Stage (
  id         TEXT PRIMARY KEY,
  ticketId   TEXT NOT NULL,
  name       TEXT NOT NULL,              -- Human-readable phase name
  key        TEXT NOT NULL,              -- Phase key (ANALYSIS, DESIGN, etc.)
  order      INTEGER NOT NULL,           -- Display order
  startedAt  DATETIME NOT NULL,
  dueAt      DATETIME,
  completedAt DATETIME,
  slaHours   INTEGER,
  decision   TEXT,                       -- APPROVE or REJECT
  comment    TEXT,
  
  -- Enhanced phase data
  phaseData  TEXT,                       -- JSON string for phase-specific fields
  assignee   TEXT,                       -- Who is responsible for this phase
  approver   TEXT,                       -- Who approved this phase
  attachments TEXT,                      -- JSON array of attachment IDs
  
  FOREIGN KEY (ticketId) REFERENCES Ticket(id) ON DELETE CASCADE
);
```

### 5. **Attachment Table**
**Purpose**: Store file attachments for tickets and stages
```sql
CREATE TABLE Attachment (
  id          TEXT PRIMARY KEY,
  ticketId    TEXT NOT NULL,
  stageId     TEXT,                      -- Optional: specific to a stage
  fileName    TEXT NOT NULL,
  originalName TEXT NOT NULL,
  fileSize    INTEGER NOT NULL,
  mimeType    TEXT NOT NULL,
  filePath    TEXT NOT NULL,
  category    TEXT,                      -- Requirements, Design, Testing, etc.
  description TEXT,
  uploadedBy  TEXT NOT NULL,
  uploadedAt  DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (ticketId) REFERENCES Ticket(id) ON DELETE CASCADE
);
```

## 🔄 Workflow Phases

### **Current Workflow Sequence:**
```
SUBMITTED → ANALYSIS → CONFIRM_DUE → DESIGN → DIGITAL_APPROVAL → 
DEVELOPMENT → TESTING → CUSTOMER_APPROVAL → DEPLOYMENT → UAT → 
VERIFICATION → CLOSED
```

### **Phase Details:**

| Phase | Name | Description | SLA Hours | Assignee Role | Color | Icon |
|-------|------|-------------|-----------|---------------|-------|------|
| **SUBMITTED** | Submitted | Initial request received | 2 | SERVICE_DESK | #9E9E9E | 📝 |
| **ANALYSIS** | Analysis | Technical analysis and feasibility | 24 | TECHNICAL_ANALYST | #FFC107 | 🔍 |
| **CONFIRM_DUE** | Confirm Due Date | Set SLA and confirm timeline | 0 | ADMIN | #2196F3 | ⏰ |
| **DESIGN** | Design | Solution design and architecture | 48 | SOLUTION_ARCHITECT | #2196F3 | 🎨 |
| **DIGITAL_APPROVAL** | Digital Approval | Digital manager approval | 24 | MANAGER | #9C27B0 | ✅ |
| **DEVELOPMENT** | Development | Implementation and coding | 168 | DEVELOPER | #4CAF50 | 💻 |
| **TESTING** | Testing | Quality assurance and testing | 24 | QA_ENGINEER | #FF9800 | 🧪 |
| **CUSTOMER_APPROVAL** | Customer Approval | Customer approval for deployment | 48 | CREATOR | #795548 | 👥 |
| **DEPLOYMENT** | Deployment | Production deployment | 4 | DEVOPS_ENGINEER | #607D8B | 🚀 |
| **UAT** | User Acceptance Testing | User acceptance testing | 48 | BUSINESS_ANALYST | #795548 | 👥 |
| **VERIFICATION** | Verification | Post-deployment verification | 8 | OPERATIONS_ENGINEER | #3F51B5 | 🔍 |
| **CLOSED** | Closed | Request completed | 24 | SERVICE_MANAGER | #4CAF50 | ✅ |

### **Special Phases:**
| Phase | Name | Description | SLA Hours | Color | Icon |
|-------|------|-------------|-----------|-------|------|
| **ON_HOLD** | On Hold | Request paused | 0 | #FFC107 | ⏸️ |
| **REJECTED** | Rejected | Request rejected | 24 | #F44336 | ❌ |
| **CANCELLED** | Cancelled | Request cancelled | 4 | #9E9E9E | 🚫 |

## 👥 User Roles and Permissions

### **Role Hierarchy:**

| Role | Display Name | Permissions | Color |
|------|--------------|-------------|-------|
| **ADMIN** | Administrator | ALL permissions | #E91E63 |
| **SERVICE_MANAGER** | Service Manager | Manage tickets, approve requests, view reports | #9C27B0 |
| **SERVICE_DESK** | Service Desk | Create/update tickets, assign tickets | #2196F3 |
| **TECHNICAL_ANALYST** | Technical Analyst | Analyze tickets, update tickets | #FF9800 |
| **SOLUTION_ARCHITECT** | Solution Architect | Design solutions, update tickets | #4CAF50 |
| **DEVELOPER** | Developer | Develop solutions, update tickets | #00BCD4 |
| **QA_ENGINEER** | QA Engineer | Test solutions, update tickets | #FF5722 |
| **BUSINESS_ANALYST** | Business Analyst | Analyze requirements, update tickets | #795548 |
| **DEVOPS_ENGINEER** | DevOps Engineer | Deploy solutions, update tickets | #607D8B |
| **OPERATIONS_ENGINEER** | Operations Engineer | Monitor systems, update tickets | #3F51B5 |
| **MANAGER** | Manager | Approve requests, view reports | #9E9E9E |
| **CREATOR** | Request Creator | Create tickets, view own tickets | #757575 |

### **Role-Based Workflow Access:**

| Role | Allowed Phases |
|------|----------------|
| **ADMIN** | All phases |
| **SERVICE_MANAGER** | ANALYSIS, CONFIRM_DUE, DESIGN, DIGITAL_APPROVAL, DEVELOPMENT, TESTING, CUSTOMER_APPROVAL, DEPLOYMENT, UAT, VERIFICATION |
| **TECHNICAL_ANALYST** | ANALYSIS, CONFIRM_DUE, DESIGN |
| **SOLUTION_ARCHITECT** | DESIGN, DIGITAL_APPROVAL |
| **DEVELOPER** | DEVELOPMENT, TESTING |
| **QA_ENGINEER** | TESTING |
| **DEVOPS_ENGINEER** | DEPLOYMENT, UAT, VERIFICATION |
| **CREATOR** | SUBMITTED, CUSTOMER_APPROVAL, UAT, VERIFICATION |

## ⏱️ SLA Configuration

### **Priority-Based SLA:**
| Priority | SLA Hours | Color | Description |
|----------|-----------|-------|-------------|
| **CRITICAL** | 2 hours | #F44336 | Critical issues requiring immediate attention |
| **HIGH** | 8 hours | #FF9800 | High priority requests |
| **MEDIUM** | 24 hours | #FFC107 | Medium priority requests |
| **LOW** | 72 hours | #4CAF50 | Low priority requests |

### **Priority Matrix:**
| Impact \ Urgency | HIGH | MEDIUM | LOW |
|------------------|------|--------|-----|
| **HIGH** | CRITICAL | HIGH | HIGH |
| **MEDIUM** | HIGH | MEDIUM | MEDIUM |
| **LOW** | MEDIUM | LOW | LOW |

## 🔗 Relationships

### **Foreign Key Relationships:**
- `Ticket.assignedToId` → `User.id`
- `Ticket.createdById` → `User.id`
- `Stage.ticketId` → `Ticket.id`
- `Attachment.ticketId` → `Ticket.id`
- `Attachment.stageId` → `Stage.id`

### **Indexes:**
- `Lookup(type, value)` - Unique constraint
- `User(email)` - Unique index
- `User(role)` - Index for role-based queries
- `Ticket(assignedToId)` - Index for assigned tickets
- `Ticket(status, assignedToId)` - Composite index for filtering
- `Stage(ticketId, order)` - Index for workflow timeline

## 📈 Key Features

### **Workflow Management:**
- ✅ 12-phase professional workflow
- ✅ Role-based access control
- ✅ SLA tracking and breach detection
- ✅ Team assignment and collaboration
- ✅ File attachments per phase
- ✅ Comments and decisions tracking
- ✅ Progress percentage tracking

### **ITSM Compliance:**
- ✅ ITIL-aligned workflow
- ✅ Priority matrix calculation
- ✅ Impact and urgency assessment
- ✅ Business justification tracking
- ✅ Risk assessment
- ✅ Quality gates
- ✅ Customer satisfaction tracking

### **Real-time Features:**
- ✅ Server-sent events for live updates
- ✅ SLA status monitoring
- ✅ MTTR calculation
- ✅ Progress tracking
- ✅ Notification system

This design provides a comprehensive, enterprise-grade project management system with full ITSM compliance and modern workflow management capabilities.
