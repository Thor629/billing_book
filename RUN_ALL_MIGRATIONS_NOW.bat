@echo off
echo ========================================
echo Running ALL Migrations for Purchase Order Conversion
echo ========================================
echo.

cd backend

echo Step 1: Running migrations...
php artisan migrate

echo.
echo Step 2: Checking migration status...
php artisan migrate:status

echo.
echo ========================================
echo Migrations Complete!
echo ========================================
echo.
echo IMPORTANT: Please restart your backend server now:
echo.
echo   cd backend
echo   php artisan serve
echo.
echo Then try converting a purchase order again.
echo.
pause
