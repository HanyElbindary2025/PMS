# PMS Batch Files & PowerShell Scripts

This folder contains batch files and PowerShell scripts to easily start and manage the PMS application.

## 🚀 Quick Start

### Option 1: Batch Files (Windows)
- **`setup-project.bat`** - First time setup (installs dependencies, sets up database)
- **`start-both.bat`** - Starts both backend and frontend servers
- **`start-backend.bat`** - Starts only the backend server
- **`start-frontend.bat`** - Starts only the frontend server
- **`start-database.bat`** - Starts Prisma Studio (database management)
- **`stop-all.bat`** - Stops all running PMS processes

### Option 2: PowerShell Scripts (Windows)
- **`start-both.ps1`** - Starts both servers with colored output
- **`start-backend.ps1`** - Starts backend with colored output
- **`start-frontend.ps1`** - Starts frontend with colored output
- **`stop-all.ps1`** - Stops all processes with colored output

## 📋 Usage Instructions

### First Time Setup
1. Double-click `setup-project.bat`
2. Wait for all dependencies to install
3. Run `start-both.bat` to start the application

### Daily Usage
1. **Start Everything**: Double-click `start-both.bat`
2. **Access Application**: 
   - Frontend: http://localhost:8080
   - Backend API: http://localhost:3000
   - Database Studio: http://localhost:5555
3. **Stop Everything**: Double-click `stop-all.bat`

### Individual Services
- **Backend Only**: `start-backend.bat`
- **Frontend Only**: `start-frontend.bat`
- **Database Studio**: `start-database.bat`

## 🔧 Troubleshooting

### If PowerShell scripts don't run:
1. Right-click PowerShell and "Run as Administrator"
2. Run: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
3. Try running the PowerShell scripts again

### If ports are already in use:
1. Run `stop-all.bat` to kill all processes
2. Wait a few seconds
3. Run `start-both.bat` again

### If dependencies are missing:
1. Run `setup-project.bat` again
2. Make sure Node.js and Flutter are installed

## 📱 Access Points

- **Web Application**: http://localhost:8080
- **Backend API**: http://localhost:3000
- **Database Studio**: http://localhost:5555
- **Health Check**: http://localhost:3000/health

## 🎯 Features

- **Automatic dependency installation**
- **Colored console output** (PowerShell)
- **Multiple window support** (each service in separate window)
- **Easy process management**
- **Error handling and status messages**
