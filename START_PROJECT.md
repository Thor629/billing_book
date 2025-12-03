# 🚀 Quick Start - Complete Project

## One-Time Setup (First Time Only)

### Backend Setup
```bash
cd backend
composer install
cp .env.example .env
```

**Edit `backend/.env` and set your database:**
```env
DB_DATABASE=saas_billing
DB_USERNAME=root
DB_PASSWORD=your_password
```

**Then run:**
```bash
php artisan key:generate
php artisan migrate
php artisan db:seed
```

### Flutter Setup
```bash
cd flutter_app
flutter pub get
```

---

## Daily Usage (Every Time)

### Start Backend (Terminal 1)
```bash
cd backend
php artisan serve
```
**Backend runs at:** `http://localhost:8000`

### Start Flutter (Terminal 2)
```bash
cd flutter_app
flutter run -d chrome
```

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

## ✅ What You Can Do

### As Admin
- Manage users (add, edit, activate, deactivate, delete)
- Manage plans (add, edit, delete)
- View dashboard metrics
- Search and filter users

### As User
- Update profile
- Change password
- Browse subscription plans
- Subscribe to plans
- View subscription status

---

## 🐛 Quick Troubleshooting

**Backend not starting?**
- Check database credentials in `.env`
- Run `composer install`

**Flutter not connecting?**
- Make sure backend is running at `http://localhost:8000`
- Check `flutter_app/lib/core/constants/app_config.dart`

**Login not working?**
- Make sure you ran `php artisan db:seed`
- Use exact credentials: `admin@example.com` / `password123`

---

## 📁 Project Structure

```
project/
├── backend/              # Laravel API
│   ├── app/
│   ├── database/
│   ├── routes/
│   └── .env             # Configure this!
│
└── flutter_app/         # Flutter Frontend
    ├── lib/
    │   ├── screens/
    │   ├── services/
    │   └── providers/
    └── pubspec.yaml
```

---

## 🎯 You're Ready!

1. Start backend: `cd backend && php artisan serve`
2. Start Flutter: `cd flutter_app && flutter run -d chrome`
3. Login: `admin@example.com` / `password123`

**Enjoy your SaaS Billing Platform!** 🎉
