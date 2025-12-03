# 🔐 Test Credentials - Quick Reference

## For Testing WITHOUT Backend Connection

### 👨‍💼 ADMIN ACCOUNT
```
Email:    admin@example.com
Password: password123
Role:     Admin
Access:   Full admin panel
```

### 👤 USER ACCOUNTS

**User 1 (Active):**
```
Email:    john@example.com
Password: password123
Role:     User
Status:   Active
```

**User 2 (Active):**
```
Email:    jane@example.com
Password: password123
Role:     User
Status:   Active
```

**User 3 (Inactive):**
```
Email:    bob@example.com
Password: password123
Role:     User
Status:   Inactive
```

---

## 🚀 Quick Setup for Testing

### 1. Enable Mock Mode (No Backend Needed)

Edit `flutter_app/lib/main.dart`:

**Line 6 - Change:**
```dart
import 'providers/auth_provider.dart';
```
**To:**
```dart
import 'providers/mock_auth_provider.dart';
```

**Line 19 - Change:**
```dart
ChangeNotifierProvider(create: (_) => AuthProvider()),
```
**To:**
```dart
ChangeNotifierProvider(create: (_) => MockAuthProvider()),
```

### 2. Run App
```bash
cd flutter_app
flutter run -d chrome
```

### 3. Login
Use any credential above!

---

## ✅ What Works in Mock Mode

- ✅ Login with test credentials
- ✅ Role-based routing (admin/user)
- ✅ All UI screens
- ✅ Navigation
- ✅ Form validation
- ✅ Logout

## ⏳ What Needs Backend

- ⏳ Real CRUD operations
- ⏳ Data persistence
- ⏳ API calls
- ⏳ Database operations

---

## 🔌 Switch to Real Backend

### 1. Start Backend
```bash
cd backend
php artisan serve
```

### 2. Update main.dart
Change back to:
```dart
import 'providers/auth_provider.dart';
ChangeNotifierProvider(create: (_) => AuthProvider()),
```

### 3. Backend Credentials
Same credentials work with real backend!

---

## 📋 Test Checklist

- [ ] Admin login works
- [ ] User login works
- [ ] Invalid login shows error
- [ ] Admin sees admin dashboard
- [ ] User sees user dashboard
- [ ] Navigation works
- [ ] Forms validate
- [ ] Logout works

---

**All passwords are:** `password123`

**Admin email:** `admin@example.com`
**User emails:** `john@example.com`, `jane@example.com`, `bob@example.com`
