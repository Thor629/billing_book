@echo off
echo ========================================
echo Running Purchase Order Migrations
echo ========================================
echo.

cd backend

echo Running migrations...
php artisan migrate

echo.
echo ========================================
echo Migrations Complete!
echo ========================================
echo.
echo Please restart your backend server:
echo   php artisan serve
echo.
pause
