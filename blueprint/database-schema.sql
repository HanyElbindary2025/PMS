-- Project Management Module Database Schema
-- Extension to existing PMS system

-- Projects table
CREATE TABLE Project (
    id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))),2) || '-' || substr('89ab',abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))),2) || '-' || lower(hex(randomblob(6)))),
    name TEXT NOT NULL,
    description TEXT,
    status TEXT NOT NULL DEFAULT 'PLANNING' CHECK (status IN ('PLANNING', 'ACTIVE', 'ON_HOLD', 'COMPLETED', 'CANCELLED')),
    startDate DATETIME,
    endDate DATETIME,
    budget DECIMAL(10,2),
    priority TEXT NOT NULL DEFAULT 'MEDIUM' CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'URGENT')),
    client TEXT,
    managerId TEXT NOT NULL,
    createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (managerId) REFERENCES User(id) ON DELETE CASCADE
);

-- Tasks table
CREATE TABLE Task (
    id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))),2) || '-' || substr('89ab',abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))),2) || '-' || lower(hex(randomblob(6)))),
    projectId TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    status TEXT NOT NULL DEFAULT 'TODO' CHECK (status IN ('TODO', 'IN_PROGRESS', 'REVIEW', 'COMPLETED', 'CANCELLED')),
    startDate DATETIME,
    endDate DATETIME,
    estimatedHours DECIMAL(5,2),
    actualHours DECIMAL(5,2) DEFAULT 0,
    assignedTo TEXT,
    priority TEXT NOT NULL DEFAULT 'MEDIUM' CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'URGENT')),
    progress INTEGER DEFAULT 0 CHECK (progress >= 0 AND progress <= 100),
    createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (projectId) REFERENCES Project(id) ON DELETE CASCADE,
    FOREIGN KEY (assignedTo) REFERENCES User(id) ON DELETE SET NULL
);

-- Task dependencies table
CREATE TABLE TaskDependency (
    id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))),2) || '-' || substr('89ab',abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))),2) || '-' || lower(hex(randomblob(6)))),
    taskId TEXT NOT NULL,
    dependsOnTaskId TEXT NOT NULL,
    dependencyType TEXT NOT NULL DEFAULT 'FINISH_TO_START' CHECK (dependencyType IN ('FINISH_TO_START', 'START_TO_START', 'FINISH_TO_FINISH', 'START_TO_FINISH')),
    createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (taskId) REFERENCES Task(id) ON DELETE CASCADE,
    FOREIGN KEY (dependsOnTaskId) REFERENCES Task(id) ON DELETE CASCADE,
    UNIQUE(taskId, dependsOnTaskId)
);

-- Project members table
CREATE TABLE ProjectMember (
    id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))),2) || '-' || substr('89ab',abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))),2) || '-' || lower(hex(randomblob(6)))),
    projectId TEXT NOT NULL,
    userId TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'MEMBER' CHECK (role IN ('MANAGER', 'LEAD', 'MEMBER', 'VIEWER')),
    permissions TEXT, -- JSON string for custom permissions
    joinedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (projectId) REFERENCES Project(id) ON DELETE CASCADE,
    FOREIGN KEY (userId) REFERENCES User(id) ON DELETE CASCADE,
    UNIQUE(projectId, userId)
);

-- Time entries table
CREATE TABLE TimeEntry (
    id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))),2) || '-' || substr('89ab',abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))),2) || '-' || lower(hex(randomblob(6)))),
    taskId TEXT,
    projectId TEXT NOT NULL,
    userId TEXT NOT NULL,
    date DATE NOT NULL,
    hours DECIMAL(4,2) NOT NULL CHECK (hours > 0),
    description TEXT,
    billable BOOLEAN DEFAULT true,
    createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (taskId) REFERENCES Task(id) ON DELETE SET NULL,
    FOREIGN KEY (projectId) REFERENCES Project(id) ON DELETE CASCADE,
    FOREIGN KEY (userId) REFERENCES User(id) ON DELETE CASCADE
);

-- Milestones table
CREATE TABLE Milestone (
    id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))),2) || '-' || substr('89ab',abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))),2) || '-' || lower(hex(randomblob(6)))),
    projectId TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    targetDate DATETIME,
    status TEXT NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'COMPLETED', 'OVERDUE')),
    completedAt DATETIME,
    createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (projectId) REFERENCES Project(id) ON DELETE CASCADE
);

-- Project templates table
CREATE TABLE ProjectTemplate (
    id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))),2) || '-' || substr('89ab',abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))),2) || '-' || lower(hex(randomblob(6)))),
    name TEXT NOT NULL,
    description TEXT,
    templateData TEXT NOT NULL, -- JSON string containing project structure
    category TEXT,
    isDefault BOOLEAN DEFAULT false,
    createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Project comments table
CREATE TABLE ProjectComment (
    id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))),2) || '-' || substr('89ab',abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))),2) || '-' || lower(hex(randomblob(6)))),
    projectId TEXT,
    taskId TEXT,
    userId TEXT NOT NULL,
    content TEXT NOT NULL,
    createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (projectId) REFERENCES Project(id) ON DELETE CASCADE,
    FOREIGN KEY (taskId) REFERENCES Task(id) ON DELETE CASCADE,
    FOREIGN KEY (userId) REFERENCES User(id) ON DELETE CASCADE
);

-- Project files table
CREATE TABLE ProjectFile (
    id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))),2) || '-' || substr('89ab',abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))),2) || '-' || lower(hex(randomblob(6)))),
    projectId TEXT,
    taskId TEXT,
    fileName TEXT NOT NULL,
    filePath TEXT NOT NULL,
    fileSize INTEGER,
    mimeType TEXT,
    uploadedBy TEXT NOT NULL,
    createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (projectId) REFERENCES Project(id) ON DELETE CASCADE,
    FOREIGN KEY (taskId) REFERENCES Task(id) ON DELETE CASCADE,
    FOREIGN KEY (uploadedBy) REFERENCES User(id) ON DELETE CASCADE
);

-- Indexes for better performance
CREATE INDEX idx_project_status ON Project(status);
CREATE INDEX idx_project_manager ON Project(managerId);
CREATE INDEX idx_task_project ON Task(projectId);
CREATE INDEX idx_task_assigned ON Task(assignedTo);
CREATE INDEX idx_task_status ON Task(status);
CREATE INDEX idx_timeentry_user ON TimeEntry(userId);
CREATE INDEX idx_timeentry_date ON TimeEntry(date);
CREATE INDEX idx_timeentry_project ON TimeEntry(projectId);
CREATE INDEX idx_milestone_project ON Milestone(projectId);
CREATE INDEX idx_projectmember_project ON ProjectMember(projectId);
CREATE INDEX idx_projectmember_user ON ProjectMember(userId);

-- Triggers for updatedAt
CREATE TRIGGER update_project_updated_at 
    AFTER UPDATE ON Project
    BEGIN
        UPDATE Project SET updatedAt = CURRENT_TIMESTAMP WHERE id = NEW.id;
    END;

CREATE TRIGGER update_task_updated_at 
    AFTER UPDATE ON Task
    BEGIN
        UPDATE Task SET updatedAt = CURRENT_TIMESTAMP WHERE id = NEW.id;
    END;

CREATE TRIGGER update_timeentry_updated_at 
    AFTER UPDATE ON TimeEntry
    BEGIN
        UPDATE TimeEntry SET updatedAt = CURRENT_TIMESTAMP WHERE id = NEW.id;
    END;

CREATE TRIGGER update_milestone_updated_at 
    AFTER UPDATE ON Milestone
    BEGIN
        UPDATE Milestone SET updatedAt = CURRENT_TIMESTAMP WHERE id = NEW.id;
    END;
