# 📁 Professional PMS System - Project Structure

## 🎯 Overview
This document provides a comprehensive overview of the organized project structure for the Professional PMS System.

## 📂 Directory Structure

```
PMS/
├── 📁 backup/                    # Backup files and archives
├── 📁 batch/                     # Windows batch files for automation
│   ├── 📄 auto-commit.bat        # Auto-commit with progress
│   ├── 📄 auto-commit-progress.bat # Enhanced progress version
│   ├── 📄 commit-all.bat         # Main commit script
│   ├── 📄 start-backend.bat      # Start backend server
│   ├── 📄 start-frontend.bat     # Start Flutter app
│   ├── 📄 start-both.bat         # Start both services
│   └── 📄 stop-all.bat           # Stop all services
├── 📁 docs/                      # Documentation and reports
│   ├── 📄 README.md              # Main project documentation
│   └── 📄 test-report.html       # Comprehensive test results
├── 📁 learn docs/                # Learning and reference materials
│   ├── 📄 index.html             # Learning index page
│   └── 📄 pds-form.html          # PDS form reference
├── 📁 logs/                      # Application logs
├── 📁 pms_app/                   # Flutter frontend application
│   ├── 📁 lib/
│   │   ├── 📁 src/
│   │   │   ├── 📁 pages/         # Flutter pages
│   │   │   │   ├── 📄 home_page.dart
│   │   │   │   ├── 📄 login_page.dart
│   │   │   │   ├── 📄 dashboard_page.dart
│   │   │   │   ├── 📄 tickets_page.dart
│   │   │   │   ├── 📄 professional_tickets_page.dart
│   │   │   │   ├── 📄 professional_dashboard_page.dart
│   │   │   │   ├── 📄 create_request_page.dart
│   │   │   │   └── 📄 user_management_page.dart
│   │   │   └── 📁 widgets/       # Reusable Flutter widgets
│   │   │       ├── 📄 team_assignment_widget.dart
│   │   │       └── 📄 file_upload_widget.dart
│   │   └── 📄 main.dart
│   ├── 📄 pubspec.yaml           # Flutter dependencies
│   └── 📄 README.md              # Flutter app documentation
├── 📁 prisma/                    # Database schema and migrations
│   ├── 📄 schema.prisma          # Database schema definition
│   ├── 📄 seed.ts                # Database seeding script
│   ├── 📁 migrations/            # Database migration files
│   └── 📄 dev.db                 # SQLite database file
├── 📁 scripts/                   # Test and utility scripts
│   ├── 📄 simple-test.js         # Backend test script
│   ├── 📄 organize-project.js    # Project organization script
│   └── 📄 test-workflow.js       # Comprehensive workflow test
├── 📁 src/                       # Backend source code
│   ├── 📁 routes/                # API route handlers
│   │   ├── 📄 public.ts          # Public endpoints
│   │   ├── 📄 tickets.ts         # Ticket management
│   │   ├── 📄 users.ts           # User management
│   │   ├── 📄 lookups.ts         # Lookup data management
│   │   ├── 📄 attachments.ts     # File upload handling
│   │   └── 📄 sse.ts             # Server-sent events
│   ├── 📄 index.ts               # Main server entry point
│   ├── 📄 workflow-config.ts     # Workflow configuration
│   └── 📄 sla.ts                 # SLA management
├── 📁 temp/                      # Temporary files
├── 📄 .env                       # Environment variables
├── 📄 .gitignore                 # Git ignore rules
├── 📄 auto-commit.ps1            # PowerShell commit script
├── 📄 package.json               # Node.js dependencies
├── 📄 package-lock.json          # Dependency lock file
├── 📄 PDS.xlsx                   # Project Data Sheet reference
├── 📄 project-summary.json       # Project summary data
├── 📄 tsconfig.json              # TypeScript configuration
└── 📄 workflow-design.md         # Workflow design documentation
```

## 🎯 Key Directories

### 📁 `src/` - Backend Source Code
- **Purpose**: Node.js/Express backend application
- **Technology**: TypeScript, Express, Prisma
- **Key Files**:
  - `index.ts` - Main server entry point
  - `routes/` - API endpoint handlers
  - `workflow-config.ts` - Workflow configuration

### 📁 `pms_app/` - Flutter Frontend
- **Purpose**: Cross-platform mobile/web application
- **Technology**: Flutter, Dart
- **Key Files**:
  - `lib/main.dart` - App entry point
  - `lib/src/pages/` - Application pages
  - `lib/src/widgets/` - Reusable components

### 📁 `prisma/` - Database Management
- **Purpose**: Database schema and migrations
- **Technology**: Prisma ORM, SQLite
- **Key Files**:
  - `schema.prisma` - Database schema
  - `seed.ts` - Demo data seeding
  - `migrations/` - Database version control

### 📁 `docs/` - Documentation
- **Purpose**: Project documentation and reports
- **Contents**:
  - `README.md` - Main documentation
  - `test-report.html` - Test results report

### 📁 `scripts/` - Automation Scripts
- **Purpose**: Testing and utility scripts
- **Contents**:
  - `simple-test.js` - Backend testing
  - `organize-project.js` - Project organization

### 📁 `batch/` - Windows Automation
- **Purpose**: Windows batch files for easy operation
- **Contents**:
  - Start/stop scripts for services
  - Auto-commit scripts with progress bars

## 🚀 Quick Start Commands

### Backend
```bash
# Install dependencies
npm install

# Setup database
npx prisma migrate dev
npx prisma db seed

# Start server
npm run dev
```

### Frontend
```bash
# Navigate to Flutter app
cd pms_app

# Install dependencies
flutter pub get

# Run app
flutter run -d chrome --web-port 8080
```

### Testing
```bash
# Run backend tests
node scripts/simple-test.js

# View test report
# Open docs/test-report.html in browser
```

### Automation
```bash
# Start both services
batch/start-both.bat

# Auto-commit changes
batch/commit-all.bat

# Stop all services
batch/stop-all.bat
```

## 📊 File Count Summary

| Directory | Files | Purpose |
|-----------|-------|---------|
| `src/` | 8 | Backend source code |
| `pms_app/` | 15+ | Flutter frontend |
| `prisma/` | 5+ | Database management |
| `docs/` | 2 | Documentation |
| `scripts/` | 3 | Test scripts |
| `batch/` | 7 | Windows automation |
| **Total** | **40+** | **Complete system** |

## 🎯 Development Workflow

1. **Backend Development**: Work in `src/` directory
2. **Frontend Development**: Work in `pms_app/` directory
3. **Database Changes**: Update `prisma/schema.prisma`
4. **Testing**: Run scripts in `scripts/` directory
5. **Documentation**: Update files in `docs/` directory
6. **Automation**: Use batch files in `batch/` directory

## 🔧 Maintenance

### Regular Tasks
- **Logs**: Check `logs/` directory for application logs
- **Backups**: Store backups in `backup/` directory
- **Temp Files**: Clean `temp/` directory periodically
- **Dependencies**: Update `package.json` and `pubspec.yaml`

### Project Organization
- Use `scripts/organize-project.js` to reorganize structure
- Keep documentation updated in `docs/` directory
- Maintain batch files for easy operation

---

**📁 Project Structure Status: ORGANIZED**

*All files properly categorized and organized for efficient development and maintenance.*
