# Flutter SaaS Billing Platform - Laravel Backend

This is the Laravel backend API for the Flutter SaaS Billing Platform.

## Requirements

- PHP 8.1 or higher
- Composer
- MySQL 8.0 or higher
- Laravel 10.x

## Installation

1. **Install Dependencies**
   ```bash
   composer install
   ```

2. **Environment Configuration**
   ```bash
   cp .env.example .env
   ```
   
   Update the `.env` file with your database credentials:
   ```
   DB_DATABASE=saas_billing
   DB_USERNAME=your_username
   DB_PASSWORD=your_password
   ```

3. **Generate Application Key**
   ```bash
   php artisan key:generate
   ```

4. **Run Database Migrations**
   ```bash
   php artisan migrate
   ```

5. **Seed Database (Optional)**
   ```bash
   php artisan db:seed
   ```

6. **Start Development Server**
   ```bash
   php artisan serve
   ```
   
   The API will be available at `http://localhost:8000`

## API Documentation

### Authentication Endpoints

- `POST /api/auth/login` - User/Admin login
- `POST /api/auth/logout` - Logout
- `POST /api/auth/refresh` - Refresh token

### Admin Endpoints

- `GET /api/admin/users` - List all users
- `POST /api/admin/users` - Create new user
- `PUT /api/admin/users/{id}` - Update user
- `PATCH /api/admin/users/{id}/status` - Update user status
- `DELETE /api/admin/users/{id}` - Delete user

- `GET /api/admin/plans` - List all plans
- `POST /api/admin/plans` - Create new plan
- `PUT /api/admin/plans/{id}` - Update plan
- `DELETE /api/admin/plans/{id}` - Delete plan

- `GET /api/admin/activity-logs` - View activity logs

### User Endpoints

- `GET /api/user/profile` - Get user profile
- `PUT /api/user/profile` - Update profile
- `PUT /api/user/profile/password` - Change password

- `GET /api/plans` - List active plans (public)
- `GET /api/user/subscription` - Get current subscription
- `POST /api/user/subscribe` - Subscribe to a plan
- `PUT /api/user/subscription/change-plan` - Change subscription plan
- `DELETE /api/user/subscription/cancel` - Cancel subscription

## Testing

Run tests with:
```bash
php artisan test
```

## Project Structure

```
backend/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── AuthController.php
│   │   │   ├── UserController.php
│   │   │   ├── PlanController.php
│   │   │   ├── SubscriptionController.php
│   │   │   └── ProfileController.php
│   │   └── Middleware/
│   │       └── AdminOnly.php
│   ├── Models/
│   │   ├── User.php
│   │   ├── Plan.php
│   │   ├── Subscription.php
│   │   └── ActivityLog.php
│   └── Services/
│       ├── UserService.php
│       ├── PlanService.php
│       ├── SubscriptionService.php
│       └── NotificationService.php
├── database/
│   ├── migrations/
│   └── seeders/
├── routes/
│   └── api.php
└── tests/
```

## Security

- All passwords are hashed using bcrypt
- API authentication via Laravel Sanctum
- CORS configured for Flutter frontend
- Input validation on all endpoints
- Role-based access control (Admin/User)

## License

MIT License
