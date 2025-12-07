# 🚀 Helping Hand Admin Dashboard - Complete Setup Guide

## 📋 What You Have Now

1. ✅ **Frontend Dashboard** - Modern Next.js admin portal
2. ✅ **Backend API** - Complete Node.js/Express server
3. ✅ **Database Schema** - PostgreSQL tables ready

---

## 🔧 Setup Instructions (Follow in Order)

### Step 1: Configure Database Connection

1. Open `backend/.env`
2. Update your PostgreSQL password:
```env
DB_PASSWORD=your_actual_postgres_password
```

### Step 2: Install Backend Dependencies

```bash
cd backend
npm install
```

### Step 3: Create Admin User

```bash
npm run seed
```

You'll see:
```
✅ Admin user created successfully!

📧 Email: admin@helpinghand.com
🔑 Password: Admin@123
```

### Step 4: Start Backend Server

```bash
npm run dev
```

Backend runs on: http://localhost:3000

### Step 5: Install Dashboard Dependencies

Open **NEW terminal**:
```bash
cd dashboard
npm install
```

### Step 6: Start Admin Dashboard

```bash
npm run dev
```

Dashboard runs on: http://localhost:3001

---

## 🔐 Login Credentials

Open browser: http://localhost:3001

**Email:** admin@helpinghand.com
**Password:** Admin@123

---

## 🎯 What You Can Do Now

### ✅ User Management
- View all registered users
- Approve/Reject new signups
- Suspend accounts
- View user details (CNIC, documents)

### ✅ Blood Donation Requests
- View all blood requests
- Filter by status/urgency/blood group
- Approve/Reject requests
- View hospital locations

### ✅ Education Support
- View student funding requests
- See documents (result, fee challan)
- Approve/Reject applications
- Track fee amounts

### ✅ Family Support
- View martyrs' family requests
- See children details
- Approve/Reject cases
- Track monthly needs

### ✅ Dashboard Analytics
- Real-time statistics
- Charts and graphs
- Recent activity feed
- Pending approvals count

---

## 🔄 Daily Usage

**Start both servers:**

Terminal 1 (Backend):
```bash
cd backend
npm run dev
```

Terminal 2 (Dashboard):
```bash
cd dashboard
npm run dev
```

Then login at: http://localhost:3001

---

## ⚠️ Important Notes

1. **Change password in production!** Update `.env` file
2. Backend must be running for dashboard to work
3. Database must be running (PostgreSQL)
4. Default port 3000 (backend), 3001 (dashboard)

---

## 🆘 Troubleshooting

**"Database connection error"**
- Check PostgreSQL is running
- Verify `.env` credentials

**"Cannot login"**
- Run `npm run seed` again
- Check backend server is running on port 3000

**"API request failed"**
- Ensure backend is running
- Check CORS settings
- Verify network connection

---

## 📁 Project Structure

```
HelpingHand/
├── lib/              # Flutter mobile app (unchanged)
├── backend/          # Node.js API server
│   ├── src/
│   │   ├── controllers/
│   │   ├── routes/
│   │   ├── middleware/
│   │   └── server.js
│   └── .env
└── dashboard/        # Next.js admin portal
    ├── src/
    │   ├── pages/
    │   ├── components/
    │   └── services/
    └── package.json
```

---

## 🎉 You're All Set!

Your complete admin dashboard is ready to use.
Happy managing! 🚀
