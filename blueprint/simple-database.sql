-- Simple MS Project Style Database Schema
-- SQLite compatible

-- Projects table
CREATE TABLE projects (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Tasks table
CREATE TABLE tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL,
    parent_id INTEGER, -- For subtasks (NULL for main tasks)
    task_name TEXT NOT NULL,
    category TEXT,
    notes TEXT,
    is_milestone BOOLEAN DEFAULT 0,
    is_active BOOLEAN DEFAULT 1,
    percent_complete INTEGER DEFAULT 0 CHECK (percent_complete >= 0 AND percent_complete <= 100),
    status TEXT DEFAULT 'Not Started' CHECK (status IN ('Not Started', 'In Progress', 'Completed', 'Late', 'On Schedule')),
    duration INTEGER, -- in days
    start_date DATE,
    finish_date DATE,
    late_start_date DATE,
    late_finish_date DATE,
    predecessors TEXT, -- comma-separated task IDs
    deadline DATE,
    resource_names TEXT,
    resource_group TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_id) REFERENCES tasks(id) ON DELETE CASCADE
);

-- Sample data
INSERT INTO projects (name, description) VALUES 
('STP Project', 'STP implementation project'),
('Mobilum Project', 'Mobilum development project'),
('NetEco Project', 'NetEco system project'),
('UNCHA Project', 'UNCHA system implementation'),
('Use Cases', 'Use cases development');

-- Sample tasks
INSERT INTO tasks (project_id, parent_id, task_name, category, notes, is_milestone, is_active, percent_complete, status, duration, start_date, finish_date, deadline, resource_names, resource_group) VALUES 
(1, NULL, 'STP Project', 'Development', 'Main project for STP', 0, 1, 70, 'Late', 30, '2024-12-01', '2024-12-31', '2024-12-31', 'John Doe, Sarah Miller', 'Development Team'),
(1, 1, 'Analysis', 'Development', 'Project analysis phase', 0, 1, 100, 'Completed', 5, '2024-12-01', '2024-12-05', '2024-12-05', 'John Doe', 'Development Team'),
(1, 1, 'RAT Meeting', 'Development', 'Requirements and Architecture Team meeting', 0, 1, 100, 'Completed', 1, '2024-12-06', '2024-12-06', '2024-12-06', 'John Doe, Sarah Miller', 'Development Team'),
(1, 1, 'Define Work Load', 'Development', 'Define project work load', 0, 1, 100, 'Completed', 2, '2024-12-07', '2024-12-08', '2024-12-08', 'John Doe', 'Development Team'),
(1, 1, 'Approve Work Load', 'Development', 'Approve defined work load', 0, 1, 100, 'Completed', 1, '2024-12-09', '2024-12-09', '2024-12-09', 'Sarah Miller', 'Development Team'),
(1, 1, 'Development', 'Development', 'Main development phase', 0, 1, 60, 'Late', 15, '2024-12-10', '2024-12-24', '2024-12-20', 'John Doe, Alex Lee', 'Development Team'),
(1, 1, 'Customer Implementation Approval', 'Development', 'Customer approval for implementation', 0, 1, 0, 'Late', 3, '2024-12-25', '2024-12-27', '2024-12-27', 'Sarah Miller', 'Development Team'),
(1, 1, 'System Implementation', 'Development', 'System implementation phase', 0, 1, 60, 'Late', 5, '2024-12-28', '2025-01-01', '2025-01-01', 'John Doe, Alex Lee', 'Development Team'),

(2, NULL, 'Mobilum Project', 'Development', 'Mobilum project implementation', 0, 1, 0, 'Late', 25, '2024-12-15', '2025-01-10', '2025-01-10', 'Mike Chen', 'Development Team'),
(2, 9, 'Analysis', 'Development', 'Mobilum analysis phase', 0, 1, 0, 'Late', 5, '2024-12-15', '2024-12-19', '2024-12-19', 'Mike Chen', 'Development Team'),
(2, 9, 'RAT Meeting', 'Development', 'Mobilum RAT meeting', 0, 1, 0, 'Late', 1, '2024-12-20', '2024-12-20', '2024-12-20', 'Mike Chen', 'Development Team'),
(2, 9, 'Define Work Load', 'Development', 'Define Mobilum work load', 0, 1, 0, 'Late', 2, '2024-12-21', '2024-12-22', '2024-12-22', 'Mike Chen', 'Development Team'),
(2, 9, 'Approve Work Load', 'Development', 'Approve Mobilum work load', 0, 1, 0, 'Late', 1, '2024-12-23', '2024-12-23', '2024-12-23', 'Mike Chen', 'Development Team'),
(2, 9, 'Development', 'Development', 'Mobilum development phase', 0, 1, 0, 'Late', 12, '2024-12-24', '2025-01-05', '2025-01-05', 'Mike Chen', 'Development Team'),
(2, 9, 'Customer Implementation Approval', 'Development', 'Mobilum customer approval', 0, 1, 0, 'Late', 2, '2025-01-06', '2025-01-07', '2025-01-07', 'Mike Chen', 'Development Team'),
(2, 9, 'System Implementation', 'Development', 'Mobilum system implementation', 0, 1, 0, 'Late', 3, '2025-01-08', '2025-01-10', '2025-01-10', 'Mike Chen', 'Development Team'),

(3, NULL, 'NetEco Project', 'Development', 'NetEco system project', 0, 1, 100, 'Completed', 20, '2024-11-01', '2024-11-20', '2024-11-20', 'Emma Wilson, David Brown', 'Development Team'),
(3, 17, 'Analysis', 'Development', 'NetEco analysis phase', 0, 1, 100, 'Completed', 3, '2024-11-01', '2024-11-03', '2024-11-03', 'Emma Wilson', 'Development Team'),
(3, 17, 'RAT Meeting', 'Development', 'NetEco RAT meeting', 0, 1, 100, 'Completed', 1, '2024-11-04', '2024-11-04', '2024-11-04', 'Emma Wilson, David Brown', 'Development Team'),
(3, 17, 'Define Work Load', 'Development', 'Define NetEco work load', 0, 1, 100, 'Completed', 2, '2024-11-05', '2024-11-06', '2024-11-06', 'Emma Wilson', 'Development Team'),
(3, 17, 'Approve Work Load', 'Development', 'Approve NetEco work load', 0, 1, 100, 'Completed', 1, '2024-11-07', '2024-11-07', '2024-11-07', 'David Brown', 'Development Team'),
(3, 17, 'Development', 'Development', 'NetEco development phase', 0, 1, 100, 'Completed', 10, '2024-11-08', '2024-11-17', '2024-11-17', 'Emma Wilson, David Brown', 'Development Team'),
(3, 17, 'Customer Implementation Approval', 'Development', 'NetEco customer approval', 0, 1, 100, 'Completed', 1, '2024-11-18', '2024-11-18', '2024-11-18', 'Emma Wilson', 'Development Team'),
(3, 17, 'System Implementation', 'Development', 'NetEco system implementation', 0, 1, 100, 'Completed', 2, '2024-11-19', '2024-11-20', '2024-11-20', 'Emma Wilson, David Brown', 'Development Team'),

(4, NULL, 'UNCHA Project', 'Development', 'UNCHA system implementation', 0, 1, 0, 'Late', 18, '2024-12-10', '2025-01-05', '2025-01-05', 'Lisa Wang', 'Development Team'),
(4, 25, 'Analysis', 'Development', 'UNCHA analysis phase', 0, 1, 0, 'Late', 4, '2024-12-10', '2024-12-13', '2024-12-13', 'Lisa Wang', 'Development Team'),
(4, 25, 'RAT Meeting', 'Development', 'UNCHA RAT meeting', 0, 1, 0, 'Late', 1, '2024-12-14', '2024-12-14', '2024-12-14', 'Lisa Wang', 'Development Team'),
(4, 25, 'Define Work Load', 'Development', 'Define UNCHA work load', 0, 1, 0, 'Late', 2, '2024-12-15', '2024-12-16', '2024-12-16', 'Lisa Wang', 'Development Team'),
(4, 25, 'Approve Work Load', 'Development', 'Approve UNCHA work load', 0, 1, 0, 'Late', 1, '2024-12-17', '2024-12-17', '2024-12-17', 'Lisa Wang', 'Development Team'),
(4, 25, 'Development', 'Development', 'UNCHA development phase', 0, 1, 0, 'Late', 8, '2024-12-18', '2024-12-27', '2024-12-27', 'Lisa Wang', 'Development Team'),
(4, 25, 'Customer Implementation Approval', 'Development', 'UNCHA customer approval', 0, 1, 0, 'Late', 2, '2024-12-28', '2024-12-29', '2024-12-29', 'Lisa Wang', 'Development Team'),
(4, 25, 'System Implementation', 'Development', 'UNCHA system implementation', 0, 1, 0, 'Late', 4, '2024-12-30', '2025-01-02', '2025-01-02', 'Lisa Wang', 'Development Team'),

(5, NULL, 'Use Cases', 'Development', 'Use cases development', 0, 1, 21, 'Late', 15, '2024-12-01', '2024-12-15', '2024-12-15', 'Multiple', 'Development Team'),
(5, 33, 'CMDB Auto Update', 'Development', 'CMDB auto update project', 0, 1, 74, 'On Schedule', 10, '2024-12-01', '2024-12-10', '2024-12-10', 'Tom Smith, Jerry Lee', 'Development Team'),
(5, 34, 'Analysis', 'Development', 'CMDB analysis phase', 0, 1, 100, 'Completed', 2, '2024-12-01', '2024-12-02', '2024-12-02', 'Tom Smith', 'Development Team'),
(5, 34, 'RAT Meeting', 'Development', 'CMDB RAT meeting', 0, 1, 100, 'Completed', 1, '2024-12-03', '2024-12-03', '2024-12-03', 'Tom Smith, Jerry Lee', 'Development Team'),
(5, 34, 'Define Work Load', 'Development', 'Define CMDB work load', 0, 1, 100, 'Completed', 1, '2024-12-04', '2024-12-04', '2024-12-04', 'Tom Smith', 'Development Team'),
(5, 34, 'Approve Work Load', 'Development', 'Approve CMDB work load', 0, 1, 100, 'Completed', 1, '2024-12-05', '2024-12-05', '2024-12-05', 'Jerry Lee', 'Development Team'),
(5, 34, 'Development', 'Development', 'CMDB development phase', 0, 1, 80, 'On Schedule', 4, '2024-12-06', '2024-12-09', '2024-12-09', 'Tom Smith, Jerry Lee', 'Development Team'),
(5, 34, 'Customer Implementation Approval', 'Development', 'CMDB customer approval', 0, 1, 0, 'Future', 1, '2024-12-10', '2024-12-10', '2024-12-10', 'Tom Smith', 'Development Team');

-- Create indexes for better performance
CREATE INDEX idx_tasks_project_id ON tasks(project_id);
CREATE INDEX idx_tasks_parent_id ON tasks(parent_id);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_start_date ON tasks(start_date);
CREATE INDEX idx_tasks_finish_date ON tasks(finish_date);

-- Create triggers for updated_at
CREATE TRIGGER update_projects_updated_at 
    AFTER UPDATE ON projects
    BEGIN
        UPDATE projects SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
    END;

CREATE TRIGGER update_tasks_updated_at 
    AFTER UPDATE ON tasks
    BEGIN
        UPDATE tasks SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
    END;
