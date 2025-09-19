# Prisma Studio Guide

## What is Prisma Studio?

**Prisma Studio** is a visual database browser and editor for your Prisma database. It provides a user-friendly web interface to view, create, edit, and delete data in your database without writing SQL queries.

## Key Features

### 🗄️ **Database Browser**
- **Visual Interface**: Browse all your database tables and relationships
- **Data Viewing**: See all records in a clean, organized table format
- **Search & Filter**: Find specific records quickly
- **Sorting**: Sort data by any column

### ✏️ **Data Management**
- **Create Records**: Add new entries to any table
- **Edit Records**: Modify existing data inline
- **Delete Records**: Remove unwanted entries
- **Bulk Operations**: Select and modify multiple records

### 🔗 **Relationship Navigation**
- **Foreign Keys**: Click to navigate between related records
- **One-to-Many**: View all related records
- **Many-to-Many**: Manage junction table relationships

## How to Use Prisma Studio

### 1. **Starting Prisma Studio**
```bash
# From your project root directory
npx prisma studio --port 5555
```

### 2. **Accessing the Interface**
- Open your web browser
- Navigate to: `http://localhost:5555`
- You'll see a list of all your database tables

### 3. **Our PMS Database Tables**

#### **📋 Lookup Table**
- **Purpose**: Stores dropdown options for forms
- **Fields**: `id`, `type`, `value`, `order`, `active`
- **Types**: PROJECT, PLATFORM, CATEGORY, PRIORITY
- **Usage**: Manage dropdown options in Admin Settings

#### **👥 User Table**
- **Purpose**: Stores user accounts and roles
- **Fields**: `id`, `email`, `name`, `role`, `department`, `phone`, `isActive`
- **Roles**: ADMIN, SERVICE_MANAGER, DEVELOPER, etc.
- **Usage**: Manage user accounts and permissions

#### **🎫 Ticket Table**
- **Purpose**: Stores all project requests and tickets
- **Fields**: `id`, `ticketNumber`, `title`, `description`, `status`, `priority`, etc.
- **Status**: SUBMITTED, ANALYSIS, DEVELOPMENT, TESTING, etc.
- **Usage**: View and manage all project requests

#### **📊 Stage Table**
- **Purpose**: Tracks workflow progress for each ticket
- **Fields**: `id`, `ticketId`, `name`, `key`, `order`, `startedAt`, `completedAt`
- **Usage**: Monitor ticket workflow progression

#### **📎 Attachment Table**
- **Purpose**: Stores file attachments for tickets
- **Fields**: `id`, `ticketId`, `fileName`, `filePath`, `mimeType`
- **Usage**: Manage file uploads and downloads

## Common Use Cases in Our PMS

### 🔧 **Admin Tasks**
1. **Manage Dropdown Options**
   - Go to `Lookup` table
   - Add new PROJECT, PLATFORM, CATEGORY, or PRIORITY options
   - Set display order for proper sorting

2. **User Management**
   - Go to `User` table
   - Create new user accounts
   - Update user roles and permissions
   - Activate/deactivate users

3. **Ticket Monitoring**
   - Go to `Ticket` table
   - View all project requests
   - Check ticket status and progress
   - Monitor SLA compliance

### 📊 **Data Analysis**
1. **Workflow Analysis**
   - Go to `Stage` table
   - See how long each phase takes
   - Identify bottlenecks in the process

2. **Performance Metrics**
   - Count tickets by status
   - Analyze priority distribution
   - Track resolution times

### 🛠️ **Troubleshooting**
1. **Data Issues**
   - Find orphaned records
   - Check data integrity
   - Verify relationships

2. **Testing**
   - Create test data
   - Verify form submissions
   - Test workflow transitions

## Best Practices

### ✅ **Do's**
- **Backup First**: Always backup your database before making changes
- **Test Changes**: Verify changes work in the application
- **Use Transactions**: For complex operations, use database transactions
- **Document Changes**: Keep track of what you modify

### ❌ **Don'ts**
- **Don't Delete Production Data**: Be very careful with delete operations
- **Don't Modify IDs**: Never change primary key values
- **Don't Break Relationships**: Ensure foreign key constraints remain valid
- **Don't Work Alone**: Have someone review critical changes

## Security Considerations

### 🔒 **Access Control**
- **Local Only**: Prisma Studio runs locally by default
- **Port Security**: Uses port 5555 (change if needed)
- **No Authentication**: Anyone with access to your machine can use it
- **Production Warning**: Never run in production without proper security

### 🛡️ **Safe Usage**
- **Development Only**: Use primarily for development and testing
- **Read-Only Mode**: Consider read-only access for production
- **Network Isolation**: Don't expose to external networks
- **Regular Backups**: Always backup before making changes

## Integration with Our PMS

### 🔄 **Workflow Integration**
- **Ticket Creation**: New tickets appear in the `Ticket` table
- **Status Updates**: Stage transitions are tracked in the `Stage` table
- **User Actions**: All user activities are logged in respective tables

### 📱 **Frontend Integration**
- **Admin Settings**: Changes in Prisma Studio reflect in the Admin Settings page
- **User Management**: User changes appear in the User Management page
- **Ticket Display**: All ticket data is pulled from these tables

### 🔧 **Backend Integration**
- **API Endpoints**: All backend APIs read/write to these tables
- **Real-time Updates**: Changes are immediately available to the application
- **Data Validation**: Prisma ensures data integrity and relationships

## Troubleshooting Common Issues

### 🚨 **Connection Issues**
```bash
# If Prisma Studio won't start
npx prisma generate
npx prisma db push
npx prisma studio --port 5555
```

### 🔧 **Data Issues**
- **Missing Records**: Check if data was actually saved
- **Relationship Errors**: Verify foreign key constraints
- **Type Mismatches**: Ensure data types match schema

### 📊 **Performance Issues**
- **Slow Loading**: Large datasets may take time to load
- **Memory Usage**: Close unused browser tabs
- **Database Locks**: Avoid concurrent modifications

## Quick Reference

### 🎯 **Common Commands**
```bash
# Start Prisma Studio
npx prisma studio --port 5555

# Generate Prisma Client
npx prisma generate

# Push schema changes
npx prisma db push

# Reset database
npx prisma migrate reset
```

### 📍 **Important URLs**
- **Prisma Studio**: `http://localhost:5555`
- **Backend API**: `http://localhost:3000`
- **Frontend App**: `http://localhost:8080`

### 🗂️ **Key Tables**
- **Lookup**: Dropdown options
- **User**: User accounts
- **Ticket**: Project requests
- **Stage**: Workflow progress
- **Attachment**: File uploads

---

**Remember**: Prisma Studio is a powerful tool for database management. Use it responsibly and always backup your data before making significant changes!
