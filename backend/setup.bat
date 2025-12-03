@echo off
echo ========================================
echo SaaS Billing Platform - Setup Script
echo ========================================
echo.

echo Step 1: Copying environment file...
if not exist .env (
    copy .env.example .env
    echo .env file created!
) else (
    echo .env file already exists.
)
echo.

echo Step 2: Installing dependencies...
call composer install
echo.

echo Step 3: Generating application key...
call php artisan key:generate
echo.

echo ========================================
echo IMPORTANT: Database Setup Required!
echo ========================================
echo.
echo Please create the database first:
echo.
echo Option 1 - Using XAMPP (Recommended):
echo   1. Start XAMPP Control Panel
echo   2. Start MySQL
echo   3. Open phpMyAdmin (click Admin button)
echo   4. Create database named: saas_billing
echo.
echo Option 2 - Using MySQL Command:
echo   mysql -u root -p
echo   CREATE DATABASE saas_billing;
echo   EXIT;
echo.
echo After creating the database, edit .env file:
echo   DB_DATABASE=saas_billing
echo   DB_USERNAME=root
echo   DB_PASSWORD=your_password
echo.
echo Then run: setup-migrate.bat
echo.
pause
