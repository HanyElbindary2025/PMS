# Project Management System (PMS)

A comprehensive full-stack project management system with workflow management, SLA tracking, and role-based access control.

## 🚀 Features

- **Complete Workflow Management**: 12-phase workflow from submission to closure
- **SLA Tracking**: Real-time SLA monitoring and breach detection
- **Role-Based Access Control**: Different permissions for different user roles
- **Team Assignment**: Assign tickets to users and teams
- **Real-time Updates**: Server-sent events for live updates
- **File Attachments**: Upload and manage files for tickets
- **Responsive UI**: Modern Flutter web application

## 🏗️ Architecture

- **Backend**: Node.js + Express + TypeScript
- **Database**: SQLite with Prisma ORM
- **Frontend**: Flutter Web
- **Real-time**: Server-Sent Events (SSE)

## 📋 Workflow Phases

1. **SUBMITTED** → **ANALYSIS** → **CONFIRM_DUE** → **DESIGN**
2. **DIGITAL_APPROVAL** → **DEVELOPMENT** → **TESTING** → **CUSTOMER_APPROVAL**
3. **DEPLOYMENT** → **UAT** → **VERIFICATION** → **CLOSED**

## 🛠️ Setup & Installation

### Prerequisites
- Node.js (v18+)
- Flutter SDK
- Git

### Backend Setup
```bash
# Install dependencies
npm install

# Setup database
npx prisma generate
npx prisma migrate dev --name init

# Start backend server
npm run dev
```

### Frontend Setup
```bash
# Navigate to Flutter app
cd pms_app

# Get Flutter dependencies
flutter pub get

# Run Flutter web app
flutter run -d web-server --web-port 8080
```

## 🌐 Access Points

- **Backend API**: http://localhost:3000
- **Flutter Web App**: http://localhost:8080
- **Prisma Studio**: http://localhost:5555

## 👥 User Roles

- **ADMIN**: Full access to all phases
- **SERVICE_MANAGER**: Management and approval phases
- **TECHNICAL_ANALYST**: Analysis and design phases
- **DEVELOPER**: Development and testing phases
- **CREATOR**: Customer approval and verification phases

## 📊 API Endpoints

### Tickets
- `GET /tickets` - List tickets with filtering
- `GET /tickets/:id` - Get ticket details
- `POST /tickets/:id/transition` - Transition ticket phase
- `POST /tickets/:id/assign` - Assign ticket to team

### Users
- `GET /users` - List users
- `POST /users` - Create user
- `PUT /users/:id` - Update user

### Public
- `POST /public/requests` - Create new ticket

## 🔧 Development

### Database Management
```bash
# View database in Prisma Studio
npx prisma studio --port 5555

# Reset database
npx prisma migrate reset

# Deploy migrations
npx prisma migrate deploy
```

### Testing
The system includes comprehensive testing for:
- Workflow transitions
- SLA tracking
- Role-based permissions
- Team assignment
- Error handling
- Performance

## 📝 License

This project is for educational and development purposes.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

---

**Status**: ✅ Production Ready
**Last Updated**: September 2025
