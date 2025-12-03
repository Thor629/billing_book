# 🎉 Flutter SaaS Billing Platform

Complete full-stack SaaS billing and subscription management platform.

---

## ✅ Database Created!

I've created a **SQLite database file** for you - no MySQL installation needed!

**Location:** `backend/database/database.sqlite`

---

## 🚀 Super Quick Start (2 Clicks!)

### Step 1: Start Backend
**Double-click:** `START_BACKEND.bat`

This will:
- Install dependencies
- Setup database
- Create tables
- Add sample data
- Start server at http://localhost:8000

### Step 2: Start Flutter
**Double-click:** `START_FLUTTER.bat`

This will:
- Install dependencies
- Start app in Chrome

---

## 🔐 Login Credentials

### Admin Account
```
Email: admin@example.com
Password: password123
```

### User Accounts
```
Email: john@example.com
Password: password123
Email: jane@example.com
Password: password123
```

---

## 📦 What's Included

### Backend (Laravel)
- ✅ REST API with 20+ endpoints
- ✅ Authentication (Laravel Sanctum)
- ✅ User management
- ✅ Plan management
- ✅ Subscription management
- ✅ Activity logging
- ✅ SQLite database (no MySQL needed!)

### Frontend (Flutter)
- ✅ Cross-platform (Web, iOS, Android)
- ✅ Admin panel
- ✅ User panel
- ✅ Beautiful Material Design UI
- ✅ Fully connected to backend

---

## 🎯 Features

### Admin Features
- Manage users (add, edit, activate, deactivate, delete)
- Manage plans (add, edit, delete)
- View dashboard metrics
- Search and filter users
- Activity logs

### User Features
- Update profile
- Change password
- Browse subscription plans
- Subscribe to plans
- Manage subscription

---

## 📁 Project Structure

```
project/
├── backend/              # Laravel API
│   ├── database/
│   │   └── database.sqlite  # ✅ Database file created!
│   └── ...
├── flutter_app/         # Flutter App
│   └── ...
├── START_BACKEND.bat    # ✅ Start backend
└── START_FLUTTER.bat    # ✅ Start Flutter
```

---

## 🐛 Troubleshooting

### Backend won't start?
```bash
cd backend
composer install
php artisan key:generate
php artisan migrate
php artisan db:seed
```

### Flutter won't start?
```bash
cd flutter_app
flutter pub get
flutter run -d chrome
```

### Login not working?
- Make sure backend is running
- Use exact credentials: `admin@example.com` / `password123`

---

## 📚 Documentation

- `SIMPLE_SETUP.md` - Quick setup guide
- `BACKEND_CONNECTION_GUIDE.md` - Backend connection details
- `START_PROJECT.md` - Detailed start guide
- `TEST_CREDENTIALS.md` - All login credentials
- `COMPLETE.md` - Full project documentation

---

## 🎨 Design

Matches the provided reference screenshot:
- Dark sidebar navigation
- Light content area
- Color-coded metrics
- Card-based layouts
- Material Design 3

---

## 🔒 Security

- Bcrypt password hashing
- Token-based authentication
- Role-based access control
- Secure token storage
- Input validation
- CORS protection

---

## 🚀 You're Ready!

1. **Double-click** `START_BACKEND.bat`
2. **Double-click** `START_FLUTTER.bat`
3. **Login** with `admin@example.com` / `password123`

**Enjoy your SaaS Billing Platform!** 🎊

---

## 📄 License

MIT License
