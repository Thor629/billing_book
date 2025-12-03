# 🔌 Backend Connection Guide

## ✅ Flutter App is Already Connected!

Your Flutter app is configured to connect to the Laravel backend at:
```
http://localhost:8000/api
```

---

## 🚀 Quick Start (3 Steps)

### Step 1: Start the Laravel Backend

```bash
cd backend

# Install dependencies (first time only)
composer install

# Setup environment (first time only)
cp .env.example .env
# Edit .env and set your database credentials

# Generate app key (first time only)
php artisan key:generate

# Run migrations (first time only)
php artisan migrate

# Seed database with sample data (first time only)
php artisan db:seed

# Start the server
php artisan serve
```

**Backend will run at:** `http://localhost:8000`

### Step 2: Run Flutter App

```bash
cd flutter_app
flutter pub get
flutter run -d chrome  # For web
flutter run            # For mobile
```

### Step 3: Login

Use these credentials:
- **Admin:** `admin@example.com` / `password123`
- **User:** `john@example.com` / `password123`

---

## 📡 API Endpoints Connected

### ✅ Authentication (Public)
- `POST /api/auth/login` - Login
- `GET /api/plans` - View plans (public)

### ✅ Authentication (Protected)
- `POST /api/auth/logout` - Logout
- `POST /api/auth/refresh` - Refresh token

### ✅ Admin Routes
- `GET /api/admin/users` - List users
- `POST /api/admin/users` - Create user
- `PUT /api/admin/users/{id}` - Update user
- `PATCH /api/admin/users/{id}/status` - Update status
- `DELETE /api/admin/users/{id}` - Delete user
- `GET /api/admin/plans` - List plans
- `POST /api/admin/plans` - Create plan
- `PUT /api/admin/plans/{id}` - Update plan
- `DELETE /api/admin/plans/{id}` - Delete plan
- `GET /api/admin/activity-logs` - View logs

### ✅ User Routes
- `GET /api/user/profile` - Get profile
- `PUT /api/user/profile` - Update profile
- `PUT /api/user/profile/password` - Change password
- `GET /api/user/subscription` - Get subscription
- `POST /api/user/subscribe` - Subscribe to plan
- `PUT /api/user/subscription/change-plan` - Change plan
- `DELETE /api/user/subscription/cancel` - Cancel subscription

---

## 🔧 Configuration Files

### Backend API Routes
**File:** `backend/routes/api.php`
- All endpoints configured ✅
- Sanctum authentication ✅
- Admin middleware ✅

### Flutter API Client
**File:** `flutter_app/lib/services/api_client.dart`
- HTTP client with auth headers ✅
- Token storage ✅
- Error handling ✅

### Flutter Services
- `auth_service.dart` - Login, logout, token refresh ✅
- `user_service.dart` - User CRUD operations ✅
- `plan_service.dart` - Plan CRUD operations ✅
- `subscription_service.dart` - Subscription management ✅
- `profile_service.dart` - Profile management ✅

### API Configuration
**File:** `flutter_app/lib/core/constants/app_config.dart`
```dart
static const String apiBaseUrl = 'http://localhost:8000/api';
```

---

## 🧪 Test the Connection

### 1. Check Backend is Running
Open browser: `http://localhost:8000`

You should see:
```json
{
  "message": "Flutter SaaS Billing Platform API",
  "version": "1.0.0",
  "status": "active"
}
```

### 2. Test Login API
```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"password123"}'
```

Should return:
```json
{
  "token": "...",
  "user": {
    "id": 1,
    "name": "Admin User",
    "email": "admin@example.com",
    "role": "admin"
  },
  "expires_at": "..."
}
```

### 3. Test Flutter Login
1. Run Flutter app
2. Login with `admin@example.com` / `password123`
3. Should see Admin Dashboard

---

## 🔒 Security Configuration

### CORS (Already Configured)
**File:** `backend/config/cors.php`
```php
'paths' => ['api/*', 'sanctum/csrf-cookie'],
'allowed_origins' => ['*'],
'supports_credentials' => true,
```

### Sanctum (Already Configured)
**File:** `backend/config/sanctum.php`
```php
'expiration' => 120, // 120 minutes
```

### Token Storage (Already Configured)
**File:** `flutter_app/lib/services/api_client.dart`
- Uses `flutter_secure_storage`
- Tokens stored securely
- Auto-included in headers

---

## 📊 Database Setup

### Required Tables (Already Created)
1. ✅ `users` - User accounts
2. ✅ `plans` - Subscription plans
3. ✅ `subscriptions` - User subscriptions
4. ✅ `activity_logs` - Audit trail
5. ✅ `personal_access_tokens` - Sanctum tokens

### Sample Data (From Seeders)
- ✅ 1 Admin user
- ✅ 3 Regular users
- ✅ 3 Plans (Basic, Pro, Enterprise)
- ✅ 2 Active subscriptions

---

## 🐛 Troubleshooting

### Issue: "Network error: ClientFailed to fetch"
**Solution:** Backend is not running
```bash
cd backend
php artisan serve
```

### Issue: "Unauthenticated" error
**Solution:** Token expired or invalid
- Logout and login again
- Check token expiration (120 minutes)

### Issue: "CORS error"
**Solution:** Check CORS configuration
```bash
# In backend/.env
SANCTUM_STATEFUL_DOMAINS=localhost,localhost:3000,127.0.0.1
```

### Issue: "Connection refused"
**Solution:** Wrong API URL
- Check `flutter_app/lib/core/constants/app_config.dart`
- Should be `http://localhost:8000/api`

### Issue: Database connection error
**Solution:** Configure database in `backend/.env`
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=saas_billing
DB_USERNAME=root
DB_PASSWORD=your_password
```

---

## 🎯 What Works Now

### Admin Features
- ✅ Login with admin credentials
- ✅ View dashboard with metrics
- ✅ Manage users (CRUD)
- ✅ Activate/deactivate users
- ✅ Manage plans (CRUD)
- ✅ Search and filter users
- ✅ View activity logs (via API)

### User Features
- ✅ Login with user credentials
- ✅ View dashboard
- ✅ Update profile
- ✅ Change password
- ✅ Browse plans
- ✅ Subscribe to plans
- ✅ View subscription status
- ✅ Change/cancel subscription

### Authentication
- ✅ Secure token-based auth
- ✅ Token expiration (120 min)
- ✅ Role-based routing
- ✅ Logout functionality

---

## 📝 Environment Variables

### Backend (.env)
```env
APP_NAME="SaaS Billing Platform"
APP_URL=http://localhost:8000
DB_DATABASE=saas_billing
DB_USERNAME=root
DB_PASSWORD=your_password
SANCTUM_STATEFUL_DOMAINS=localhost,localhost:3000,127.0.0.1
```

### Flutter (app_config.dart)
```dart
static const String apiBaseUrl = 'http://localhost:8000/api';
```

---

## 🚀 Production Deployment

### Backend
1. Set `APP_ENV=production`
2. Set `APP_DEBUG=false`
3. Configure production database
4. Set up SSL certificate
5. Update `SANCTUM_STATEFUL_DOMAINS`

### Flutter
1. Update `apiBaseUrl` to production URL
2. Build for production:
   ```bash
   flutter build web
   flutter build apk --release
   flutter build ios --release
   ```

---

## ✅ Connection Status

- ✅ Backend API: Ready
- ✅ Flutter App: Connected
- ✅ Authentication: Working
- ✅ All Endpoints: Configured
- ✅ CORS: Enabled
- ✅ Token Storage: Secure
- ✅ Error Handling: Implemented

---

## 🎉 You're All Set!

**Just run these two commands:**

```bash
# Terminal 1 - Backend
cd backend && php artisan serve

# Terminal 2 - Flutter
cd flutter_app && flutter run -d chrome
```

**Then login with:**
- Admin: `admin@example.com` / `password123`
- User: `john@example.com` / `password123`

**Everything will work with real data from the database!** 🚀
