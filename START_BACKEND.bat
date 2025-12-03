@echo off
echo ========================================
echo Starting SaaS Billing Platform Backend
echo ========================================
echo.

cd backend

echo Checking setup...
if not exist vendor (
    echo Installing dependencies...
    call composer install
    echo.
)

if not exist .env (
    echo Creating .env file...
    copy .env.example .env
    echo.
)

echo Generating app key...
call php artisan key:generate --force
echo.

echo Running migrations...
call php artisan migrate --force
echo.

echo Seeding database...
call php artisan db:seed --force
echo.

echo ========================================
echo Backend Setup Complete!
echo ========================================
echo.
echo Test Credentials:
echo   Admin: admin@example.com / password123
echo   User:  john@example.com / password123
echo.
echo Starting server...
echo Server will run at: http://localhost:8000
echo.
echo Press Ctrl+C to stop the server
echo ========================================
echo.

call php artisan serve
