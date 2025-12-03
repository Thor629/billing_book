# Flutter SaaS Billing Platform

A cross-platform subscription management application built with Flutter.

## Features

- ✅ Unified login for admin and users
- ✅ Role-based routing (Admin/User dashboards)
- ✅ Secure token-based authentication
- ✅ Dark sidebar navigation
- ✅ Responsive design
- ✅ Material Design 3

## Getting Started

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Chrome (for web development)

### Installation

1. **Install Dependencies**
   ```bash
   cd flutter_app
   flutter pub get
   ```

2. **Configure API Base URL**
   
   Edit `lib/core/constants/app_config.dart` and update the API base URL:
   ```dart
   static const String apiBaseUrl = 'http://your-api-url/api';
   ```

3. **Run the App**
   
   For web:
   ```bash
   flutter run -d chrome
   ```
   
   For mobile:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── core/
│   └── constants/
│       ├── app_colors.dart       # Color palette
│       ├── app_config.dart       # API configuration
│       └── app_text_styles.dart  # Typography
├── models/
│   ├── user_model.dart           # User data model
│   ├── plan_model.dart           # Plan data model
│   └── subscription_model.dart   # Subscription data model
├── providers/
│   └── auth_provider.dart        # Authentication state management
├── services/
│   ├── api_client.dart           # HTTP client wrapper
│   └── auth_service.dart         # Authentication service
├── screens/
│   ├── auth/
│   │   └── login_screen.dart     # Login page
│   ├── admin/
│   │   └── admin_dashboard.dart  # Admin dashboard
│   └── user/
│       └── user_dashboard.dart   # User dashboard
└── main.dart                     # App entry point
```

## Design System

### Colors
- Primary Dark: `#2D3250` (Sidebar)
- Primary Light: `#424769` (Hover states)
- Background: `#F8F9FA`
- Success: `#10B981` (Green)
- Warning: `#EF4444` (Red)
- Info: `#3B82F6` (Blue)

### Typography
- Font Family: Inter (via Google Fonts)
- H1: 24px, Semibold
- H2: 20px, Semibold
- H3: 16px, Semibold
- Body: 14px, Regular

## Test Credentials

**Admin:**
- Email: admin@example.com
- Password: password123

**Users:**
- Email: john@example.com
- Password: password123

## Available Screens

### Implemented
- ✅ Login Screen
- ✅ Admin Dashboard (basic)
- ✅ User Dashboard (basic)

### Coming Soon
- User Management Screen
- Plan Management Screen
- Profile Screen
- Plans Browsing Screen
- Subscription Management Screen

## State Management

The app uses Provider for state management:
- `AuthProvider`: Manages authentication state and user data

## API Integration

The app communicates with the Laravel backend via REST API:
- Base URL configured in `app_config.dart`
- Authentication tokens stored securely using `flutter_secure_storage`
- All authenticated requests include Bearer token in headers

## Building for Production

### Web
```bash
flutter build web
```

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## License

MIT License
