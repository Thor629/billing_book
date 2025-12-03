# 🧪 Testing Guide - Flutter SaaS Billing Platform

## 🔐 Test Credentials (Works WITHOUT Backend)

### 👨‍💼 Admin Account
```
Email: admin@example.com
Password: password123
```
**Access:** Full admin panel, user management, plan management

### 👤 User Accounts

**Active User 1:**
```
Email: john@example.com
Password: password123
```

**Active User 2:**
```
Email: jane@example.com
Password: password123
```

**Inactive User:**
```
Email: bob@example.com
Password: password123
```

**Access:** User dashboard, profile management, plans browsing

---

## 🚀 Quick Start (Test UI Without Backend)

### Step 1: Use Mock Authentication

Update `flutter_app/lib/main.dart`:

```dart
// Change line 6 from:
import 'providers/auth_provider.dart';

// To:
import 'providers/mock_auth_provider.dart';

// Change line 19 from:
ChangeNotifierProvider(create: (_) => AuthProvider()),

// To:
ChangeNotifierProvider(create: (_) => MockAuthProvider()),
```

### Step 2: Run the App

```bash
cd flutter_app
flutter pub get
flutter run -d chrome  # For web
flutter run            # For mobile
```

### Step 3: Login

Use any of the test credentials above!

---

## ✅ What You Can Test (No Backend Needed)

### Login Screen
- ✅ Email/password validation
- ✅ Show/hide password toggle
- ✅ Loading state
- ✅ Error messages
- ✅ Role-based routing

### Admin Features
- ✅ Dashboard with metrics
- ✅ User management screen UI
- ✅ Plan management screen UI
- ✅ Add user dialog
- ✅ Add plan dialog
- ✅ Search and filters UI
- ✅ Navigation

### User Features
- ✅ User dashboard
- ✅ Profile screen with forms
- ✅ Password change form
- ✅ Plans browsing with pricing toggle
- ✅ Subscribe dialog
- ✅ Navigation

---

## 🧪 Test Scenarios

### Test 1: Admin Login
1. Email: `admin@example.com`
2. Password: `password123`
3. Click "Sign In"
4. **Expected:** Admin Dashboard with metrics

### Test 2: User Login
1. Email: `john@example.com`
2. Password: `password123`
3. Click "Sign In"
4. **Expected:** User Dashboard with subscription info

### Test 3: Invalid Login
1. Email: `wrong@email.com`
2. Password: `anything`
3. Click "Sign In"
4. **Expected:** Error message "Invalid email or password"

### Test 4: Admin Navigation
1. Login as admin
2. Click "Users" in sidebar
3. **Expected:** User management screen
4. Click "Plans" in sidebar
5. **Expected:** Plan management screen

### Test 5: User Navigation
1. Login as user
2. Click "My Profile" in sidebar
3. **Expected:** Profile form
4. Click "Plans" in sidebar
5. **Expected:** Plans grid with pricing

---

## 📱 All Test Credentials Summary

| Email | Password | Role | Status | Dashboard |
|-------|----------|------|--------|-----------|
| admin@example.com | password123 | Admin | Active | Admin Panel |
| john@example.com | password123 | User | Active | User Panel |
| jane@example.com | password123 | User | Active | User Panel |
| bob@example.com | password123 | User | Inactive | User Panel |

---

## 🔌 Connect to Backend (When Ready)

### Step 1: Start Backend
```bash
cd backend
composer install
php artisan migrate
php artisan db:seed
php artisan serve
```

### Step 2: Update Flutter to Use Real API

In `flutter_app/lib/main.dart`:
```dart
// Change back to:
import 'providers/auth_provider.dart';
ChangeNotifierProvider(create: (_) => AuthProvider()),
```

### Step 3: Update API URL

In `flutter_app/lib/core/constants/app_config.dart`:
```dart
static const String apiBaseUrl = 'http://localhost:8000/api';
```

### Step 4: Test with Real Backend

Now all CRUD operations will work with real data!

---

## 🎯 Quick Reference

**Test WITHOUT Backend:**
- Use `MockAuthProvider`
- Test UI and navigation
- Test form validation
- Test responsive design

**Test WITH Backend:**
- Use `AuthProvider`
- Test real CRUD operations
- Test API integration
- Test data persistence

---

**Start Testing Now!**

**Admin:** `admin@example.com` / `password123`
**User:** `john@example.com` / `password123`
