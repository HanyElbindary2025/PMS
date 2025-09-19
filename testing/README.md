# PMS Testing Suite

This folder contains comprehensive testing tools for the Project Management System (PMS).

## 📁 Folder Structure

```
testing/
├── README.md                           # This file
├── test-simplified-workflow.js         # Basic workflow tester
├── enhanced-workflow-tester.js         # Enhanced tester with logging
├── run-tester.bat                      # Windows batch file for basic tests
├── run-tester.ps1                      # PowerShell script for basic tests
├── run-enhanced-tests.bat              # Windows batch file for enhanced tests
├── run-enhanced-tests.ps1              # PowerShell script for enhanced tests
├── logs/                               # Test execution logs (auto-created)
└── reports/                            # Test reports (auto-created)
```

## 🚀 Quick Start

### Basic Testing
```bash
# Windows
run-tester.bat

# PowerShell
.\run-tester.ps1

# Direct command
node test-simplified-workflow.js
```

### Enhanced Testing (with logging)
```bash
# Windows
run-enhanced-tests.bat

# PowerShell
.\run-enhanced-tests.ps1

# Direct command
node enhanced-workflow-tester.js
```

## 📊 Test Results Analysis

### Your Latest Test Results:
```
✅ WORKFLOW TEST: SUCCESS
- Ticket Created: cmfrfw8960027fq7zxbawy2iy
- All Transitions: ✅ SUCCESS
  - SUBMITTED → ANALYSIS ✅
  - ANALYSIS → CONFIRM_DUE ✅
  - CONFIRM_DUE → DESIGN ✅
  - DESIGN → DEVELOPMENT ✅
  - DEVELOPMENT → TESTING ✅
  - TESTING → CUSTOMER_APPROVAL ✅
  - CUSTOMER_APPROVAL → DEPLOYMENT ✅ (with email attachment)
  - DEPLOYMENT → VERIFICATION ✅
  - VERIFICATION → CLOSED ✅

✅ SLA STATUS: WORKING
- SLA Status: WITHIN_SLA_48.0H_REMAINING
- Total SLA Hours: 48
- SLA Tracking: ✅ Working correctly

✅ ROLE PERMISSIONS: WORKING
- ADMIN: ✅ Can create tickets
- DEVELOPER: ✅ Can create tickets  
- CREATOR: ✅ Can create tickets

⚠️ Team Assignment: Failed (expected - no users exist yet)

📊 Test Duration: 6.22 seconds
```

## 🔍 What Each Test Does

### Basic Workflow Test (`test-simplified-workflow.js`)
- Creates a test ticket
- Tests all workflow transitions
- Tests customer approval with email attachment
- Tests SLA status
- Tests role permissions
- Provides console output only

### Enhanced Workflow Test (`enhanced-workflow-tester.js`)
- Everything from basic test PLUS:
- **Comprehensive logging** to files
- **Database state monitoring**
- **Detailed API request/response logging**
- **Test reports generation**
- **Error tracking and analysis**
- **Performance metrics**

## 📝 Log Files

### Log Format
Each log entry contains:
```json
{
  "timestamp": "2025-09-19T22:57:09.785Z",
  "type": "success|error|warning|info",
  "message": "Human readable message",
  "data": {
    // Additional structured data
  }
}
```

### Log Locations
- **Basic tests**: Console output only
- **Enhanced tests**: 
  - `testing/logs/test-YYYY-MM-DDTHH-mm-ss-sssZ.log`
  - `testing/reports/test-report-YYYY-MM-DDTHH-mm-ss-sssZ.json`

## 🛠️ Troubleshooting

### Common Issues

1. **"Assigned user not found"**
   - This is expected - no users exist in the database yet
   - Team assignment will work once users are created

2. **"Invalid payload"**
   - Check that the backend server is running on port 3000
   - Verify the API endpoint format

3. **"Connection refused"**
   - Start the backend server: `npm run dev`
   - Check if port 3000 is available

### Debug Mode
For detailed debugging, check the log files in `testing/logs/` directory.

## 📈 Performance Metrics

- **Average test duration**: ~6 seconds
- **Workflow completion**: 100% success rate
- **SLA tracking**: Working correctly
- **Role permissions**: All roles functional

## 🎯 Test Coverage

✅ **Workflow Transitions**: All 9 phases tested
✅ **SLA Management**: Status tracking and calculation
✅ **Email Attachments**: Customer approval with email
✅ **Role Permissions**: Admin, Developer, Creator roles
✅ **API Endpoints**: All major endpoints tested
✅ **Database Operations**: Create, read, update operations
✅ **Error Handling**: Graceful error handling and reporting

## 🔄 Continuous Testing

To run tests automatically:
1. Use the batch files for scheduled testing
2. Check log files for automated monitoring
3. Use reports for trend analysis

## 📞 Support

If you encounter issues:
1. Check the log files first
2. Verify backend server is running
3. Check database connectivity
4. Review the test reports for detailed error information
