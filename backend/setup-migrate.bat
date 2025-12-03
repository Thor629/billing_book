@echo off
echo ========================================
echo Running Database Migrations
echo ========================================
echo.

echo Creating database tables...
call php artisan migrate
echo.

echo Adding sample data...
call php artisan db:seed
echo.

echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo Test credentials:
echo   Admin: admin@example.com / password123
echo   User:  john@example.com / password123
echo.
echo To start the server, run:
echo   php artisan serve
echo.
pause
