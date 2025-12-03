# Quick Database Setup Guide

## ✅ Database File Created!

The SQLite database file has been created at: `backend/database/database.sqlite`

## Next Steps

### 1. Install Composer (if not already installed)

Download and install Composer from: https://getcomposer.org/download/

Or use this direct link for Windows: https://getcomposer.org/Composer-Setup.exe

### 2. Install Laravel Dependencies

Open a terminal in the `backend` folder and run:

```bash
composer install
```

### 3. Generate Application Key

```bash
php artisan key:generate
```

### 4. Run Database Migrations

This will create all the tables in your SQLite database:

```bash
php artisan migrate:fresh --seed
```

The `--seed` flag will also populate the database with sample data including:
- Admin user: admin@example.com / password
- Regular user: user@example.com / password
- Sample subscription plans
- Sample subscriptions

### 5. Start the Backend Server

```bash
php artisan serve
```

The API will be available at: http://localhost:8000

## Quick Test

Once the server is running, test the API:

```bash
curl http://localhost:8000/api/health
```

You should see: `{"status":"ok"}`

## Database Location

Your SQLite database is located at:
```
backend/database/database.sqlite
```

You can open this file with any SQLite browser tool to view the data.

## Troubleshooting

### PHP Not Found
Install PHP 8.1 or higher from: https://windows.php.net/download/

### Composer Not Found
Make sure Composer is installed and added to your system PATH.

### Permission Errors
Run your terminal as Administrator if you encounter permission issues.
