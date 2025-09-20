# PMS System - Batch Files

This folder contains batch files to easily manage the PMS system.

## 🚀 **Quick Start:**

### **Start Everything:**
```bash
batch\start-all.bat
```
This will:
- Stop any existing processes
- Start the backend server (Node.js)
- Start the Flutter frontend
- Open your browser automatically

### **Stop Everything:**
```bash
batch\stop-all.bat
```
This will stop all running services.

### **Test System:**
```bash
batch\test-system.bat
```
This will test if the backend is running correctly.

## 🌐 **System URLs:**
- **Backend**: http://localhost:3000
- **Frontend**: http://localhost:8080

## 👥 **Test Accounts:**
- **admin@pms.com** (Admin - Full permissions)
- **developer@pms.com** (Developer)
- **qa@pms.com** (QA Engineer)

## 📋 **Manual Commands:**

If you prefer to run manually:

### **Backend:**
```bash
npm run dev
```

### **Frontend:**
```bash
cd pms_app
flutter run -d web-server --web-port 8080
```

## 🔧 **Troubleshooting:**

If you get errors:
1. Run `batch\stop-all.bat` first
2. Then run `batch\start-all.bat`
3. Wait for both services to start completely
4. Open http://localhost:8080 in your browser