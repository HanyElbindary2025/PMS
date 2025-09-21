# Testing Folder

This folder contains testing scripts for the PMS system.

## Available Tests

### 🧪 **test-workflow.js**
- Tests the complete workflow from ticket creation to closure
- Verifies all transitions and assignments
- **Usage**: `node test-workflow.js`

## Test Reports

- **Logs**: Check the `logs/` folder for detailed test logs
- **Reports**: Check the `reports/` folder for JSON test reports

## Running Tests

1. Make sure the system is running (`start-pms.bat`)
2. Run the test: `node test-workflow.js`
3. Check the generated reports in the respective folders

## Test Data

Tests use the following accounts:
- `admin@pms.com` (Admin)
- `developer@pms.com` (Developer)
- `qa@pms.com` (QA Engineer)