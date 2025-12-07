# Helping Hand Backend API

Node.js/Express backend for Helping Hand Admin Dashboard

## Setup Instructions

### 1. Install Dependencies
```bash
cd backend
npm install
```

### 2. Configure Database
Edit `.env` file and update your PostgreSQL credentials:
```
DB_HOST=localhost
DB_PORT=5432
DB_NAME=helpinghand_db
DB_USER=postgres
DB_PASSWORD=your_actual_password
```

### 3. Create Admin User
```bash
npm run seed
```

This will create an admin account with:
- **Email:** admin@helpinghand.com
- **Password:** Admin@123

### 4. Start Server
```bash
npm run dev
```

Server will run on http://localhost:3000

## Default Admin Credentials

📧 **Email:** admin@helpinghand.com
🔑 **Password:** Admin@123

**⚠️ Change these in production!**

## API Endpoints

### Admin Authentication
- POST `/api/admin/login` - Admin login
- GET `/api/admin/profile` - Get admin profile
- POST `/api/admin/logout` - Logout

### Users Management
- GET `/api/admin/users` - Get all users
- GET `/api/admin/users/:id` - Get user by ID
- PUT `/api/admin/users/:id/approve` - Approve user
- PUT `/api/admin/users/:id/reject` - Reject user
- PUT `/api/admin/users/:id/suspend` - Suspend user

### Blood Requests
- GET `/api/admin/blood-requests` - Get all blood requests
- GET `/api/admin/blood-requests/:id` - Get request by ID
- PUT `/api/admin/blood-requests/:id/approve` - Approve request
- PUT `/api/admin/blood-requests/:id/reject` - Reject request

### Education Requests
- GET `/api/admin/education-requests` - Get all education requests
- GET `/api/admin/education-requests/:id` - Get request by ID
- PUT `/api/admin/education-requests/:id/approve` - Approve request
- PUT `/api/admin/education-requests/:id/reject` - Reject request

### Family Requests
- GET `/api/admin/family-requests` - Get all family requests
- GET `/api/admin/family-requests/:id` - Get request by ID
- PUT `/api/admin/family-requests/:id/approve` - Approve request
- PUT `/api/admin/family-requests/:id/reject` - Reject request

### Dashboard
- GET `/api/admin/dashboard/stats` - Get dashboard statistics
- GET `/api/admin/dashboard/activity` - Get recent activity
- GET `/api/admin/dashboard/charts` - Get chart data
