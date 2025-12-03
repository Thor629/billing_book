@echo off
echo ========================================
echo SaaS Billing Platform - Database Setup
echo ========================================
echo.

cd backend

echo Step 1: Installing Composer dependencies...
composer install
if %errorlevel% neq 0 (
    echo ERROR: Composer install failed. Make sure Composer is installed.
    echo Download from: https://getcomposer.org/download/
    pause
    exit /b 1
)
echo.

echo Step 2: Generating application key...
php artisan key:generate
if %errorlevel% neq 0 (
    echo ERROR: Failed to generate app key.
    pause
    exit /b 1
)
echo.

echo Step 3: Running database migrations and seeders...
php artisan migrate:fresh --seed
if %errorlevel% neq 0 (
    echo ERROR: Migration failed.
    pause
    exit /b 1
)
echo.

echo ========================================
echo SUCCESS! Database setup complete!
echo ========================================
echo.
echo Database file: backend\database\database.sqlite
echo.
echo Test credentials:
echo   Admin: admin@example.com / password
echo   User:  user@example.com / password
echo.
echo To start the server, run: START_BACKEND.bat
echo.
pause
