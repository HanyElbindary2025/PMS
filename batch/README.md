# PMS System - Batch Files

This folder contains batch files for easy management of the PMS system.

## Available Commands

### 🚀 **start-all.bat**
- Starts both backend and frontend services
- Sets up environment variables
- Opens both services in separate windows
- **Usage**: Double-click or run from command line

### 🛑 **stop-all.bat**
- Stops all running services (Node.js, Flutter, Dart)
- Cleans up all processes
- **Usage**: Double-click or run from command line

### 🗄️ **open-database.bat**
- Opens Prisma Studio for database management
- Access at: http://localhost:5555
- **Usage**: Double-click or run from command line

### 🧪 **test-system.bat**
- Tests if all services are running
- Checks backend, frontend, and database studio
- **Usage**: Double-click or run from command line

## System URLs

- **Main Application**: http://localhost:8080
- **Backend API**: http://localhost:3000
- **Database Studio**: http://localhost:5555

## Test Accounts

- `admin@pms.com` (Admin - Full access)
- `developer@pms.com` (Developer - Development tasks)
- `qa@pms.com` (QA Engineer - Testing tasks)

## Quick Start

1. **Start System**: Run `start-all.bat`
2. **Wait 30 seconds** for services to start
3. **Open Browser**: Go to http://localhost:8080
4. **Login**: Use any test account above

## Troubleshooting

- **Port conflicts**: Run `stop-all.bat` first, then `start-all.bat`
- **Database issues**: Run `open-database.bat` to check database
- **Service status**: Run `test-system.bat` to verify all services