# Render Deployment Guide for PMS Project

## 🎯 Deployment Options

### Option 1: Static Site (Blueprint Only)
**Best for**: MS Project-style task management system
**Files**: `blueprint/ms-project-table.html`

### Option 2: Web Service (Full PMS System)
**Best for**: Complete PMS with backend API
**Files**: All project files

## 📋 Pre-Deployment Setup

### 1. Create Production Package.json
```json
{
  "name": "pms-backend",
  "version": "1.0.0",
  "description": "Project Management System Backend",
  "main": "src/index.ts",
  "scripts": {
    "start": "node dist/index.js",
    "build": "tsc",
    "dev": "ts-node src/index.ts",
    "prisma:generate": "prisma generate",
    "prisma:push": "prisma db push",
    "prisma:seed": "ts-node prisma/seed.ts"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "prisma": "^5.7.1",
    "@prisma/client": "^5.7.1"
  },
  "devDependencies": {
    "@types/express": "^4.17.21",
    "@types/cors": "^2.8.17",
    "@types/node": "^20.10.5",
    "typescript": "^5.3.3",
    "ts-node": "^10.9.2"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
```

### 2. Environment Variables for Render
```env
DATABASE_URL="postgresql://username:password@host:port/database"
PORT=10000
NODE_ENV=production
```

### 3. Build Script
```bash
npm run build
npm run prisma:generate
npm run prisma:push
```

## 🚀 Deployment Steps

### For Static Site (Blueprint):
1. Go to Render Dashboard
2. Click "New Static Site"
3. Connect your GitHub repository
4. Set build command: `echo "Static site"`
5. Set publish directory: `blueprint`
6. Deploy

### For Web Service (Full System):
1. Go to Render Dashboard
2. Click "New Web Service"
3. Connect your GitHub repository
4. Set build command: `npm install && npm run build && npm run prisma:generate`
5. Set start command: `npm start`
6. Add environment variables
7. Deploy

## 📁 Required Files for Deployment

### Static Site Files:
- `blueprint/ms-project-table.html`
- `blueprint/tasks.csv`
- `PROJECT_SUMMARY.md`

### Web Service Files:
- All source files
- `package.json` (production version)
- `tsconfig.json`
- `prisma/schema.prisma`
- Environment variables

## 🔧 Database Setup

### For Production:
1. Create PostgreSQL database on Render
2. Update DATABASE_URL in environment variables
3. Run Prisma migrations
4. Seed initial data

## 📝 Next Steps

1. Choose deployment option
2. Prepare files according to guide
3. Push to GitHub
4. Deploy on Render
5. Configure environment variables
6. Test deployment

---
*Ready for deployment!*
