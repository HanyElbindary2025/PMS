# 🚀 PMS Deployment Guide - Vercel + Railway

## 📋 **Overview**
This guide will help you deploy your PMS (Project Management System) to production using:
- **Frontend (Flutter Web)** → Vercel
- **Backend (Node.js)** → Railway
- **Database (PostgreSQL)** → Railway (included)

## 🎯 **Step 1: Deploy Backend to Railway**

### 1.1 Create Railway Account
1. Go to [railway.app](https://railway.app)
2. Sign up with GitHub
3. Connect your GitHub repository

### 1.2 Deploy Backend
1. Click "New Project"
2. Select "Deploy from GitHub repo"
3. Choose your PMS repository
4. Railway will auto-detect it's a Node.js project

### 1.3 Add PostgreSQL Database
1. In your Railway project dashboard
2. Click "New" → "Database" → "PostgreSQL"
3. Railway will create a PostgreSQL database
4. Copy the connection string

### 1.4 Configure Environment Variables
In Railway project settings, add these environment variables:

```
DATABASE_URL=postgresql://username:password@host:port/database
NODE_ENV=production
PORT=3000
```

### 1.5 Update Prisma for PostgreSQL
```bash
# Update your schema.prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}
```

### 1.6 Deploy
Railway will automatically deploy when you push to GitHub.

## 🎯 **Step 2: Deploy Frontend to Vercel**

### 2.1 Create Vercel Account
1. Go to [vercel.com](https://vercel.com)
2. Sign up with GitHub
3. Connect your GitHub repository

### 2.2 Configure Build Settings
In Vercel project settings:

**Build Command:**
```bash
cd pms_app && flutter build web --web-renderer html
```

**Output Directory:**
```
pms_app/build/web
```

**Install Command:**
```bash
npm install && cd pms_app && flutter pub get
```

### 2.3 Environment Variables
Add these environment variables in Vercel:

```
BACKEND_URL=https://your-railway-app.railway.app
```

### 2.4 Update Flutter App
Update your Flutter app to use the production backend URL:

```dart
// In your Flutter app, update the base URL
const String baseUrl = String.fromEnvironment(
  'BACKEND_URL',
  defaultValue: 'http://localhost:3000',
);
```

## 🎯 **Step 3: Update Flutter App for Production**

### 3.1 Update API Base URL
Create a configuration file:

```dart
// lib/config/app_config.dart
class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://localhost:3000',
  );
}
```

### 3.2 Update All API Calls
Replace hardcoded URLs with the config:

```dart
// Before
final response = await http.get(Uri.parse('http://localhost:3000/users'));

// After
final response = await http.get(Uri.parse('${AppConfig.baseUrl}/users'));
```

## 🎯 **Step 4: Database Migration**

### 4.1 Run Prisma Migration
```bash
# In your Railway deployment, run:
npx prisma migrate deploy
npx prisma generate
```

### 4.2 Seed Initial Data
```bash
# Create a seed script to populate initial data
npm run seed
```

## 🎯 **Step 5: Test Deployment**

### 5.1 Test Backend
1. Visit your Railway URL: `https://your-app.railway.app`
2. Test endpoints: `/health`, `/users`, `/tickets`

### 5.2 Test Frontend
1. Visit your Vercel URL: `https://your-app.vercel.app`
2. Test login, create tickets, workflow

### 5.3 Test Integration
1. Create a ticket in the frontend
2. Verify it appears in the backend
3. Test the complete workflow

## 🎯 **Step 6: Share with Team**

### 6.1 Team Access
- **Frontend URL:** `https://your-app.vercel.app`
- **Backend URL:** `https://your-app.railway.app`
- **Admin Panel:** Railway dashboard for monitoring

### 6.2 Test Accounts
Create test accounts for your team:
- Admin: `admin@yourcompany.com`
- Developer: `dev@yourcompany.com`
- QA: `qa@yourcompany.com`

## 🔧 **Troubleshooting**

### Common Issues:

1. **Build Fails on Vercel**
   - Check Flutter version compatibility
   - Ensure all dependencies are in pubspec.yaml

2. **Backend Connection Issues**
   - Verify environment variables
   - Check Railway logs for errors

3. **Database Connection Issues**
   - Verify DATABASE_URL format
   - Check PostgreSQL service status

## 📊 **Monitoring**

### Railway Monitoring:
- View logs in Railway dashboard
- Monitor resource usage
- Set up alerts for errors

### Vercel Monitoring:
- View build logs
- Monitor performance
- Check analytics

## 🚀 **Scaling**

### When Ready to Scale:
1. **Upgrade Railway Plan** for more resources
2. **Add Custom Domain** to Vercel
3. **Set up CDN** for better performance
4. **Add Monitoring** (Sentry, LogRocket)

## 📞 **Support**

- **Railway Docs:** [docs.railway.app](https://docs.railway.app)
- **Vercel Docs:** [vercel.com/docs](https://vercel.com/docs)
- **Flutter Web:** [flutter.dev/web](https://flutter.dev/web)

---

## 🎉 **You're Ready!**

Once deployed, your team can access:
- **Production URL:** `https://your-app.vercel.app`
- **Admin Access:** Railway dashboard
- **Real-time Testing:** Full workflow testing

**Happy Testing!** 🚀
