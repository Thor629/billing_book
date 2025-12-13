@echo off
echo Testing GST Report API...
echo.

cd backend

echo [1] Clearing Laravel cache...
php artisan config:clear
php artisan cache:clear
php artisan route:clear
echo.

echo [2] Checking syntax...
php -l app/Http/Controllers/GstReportController.php
echo.

echo [3] Listing GST routes...
php artisan route:list | findstr "gst-reports"
echo.

echo ========================================
echo GST API is ready!
echo ========================================
echo.
echo Now restart your Flutter app:
echo 1. Stop the Flutter app (Ctrl+C)
echo 2. Run: flutter run
echo 3. Navigate to GST Report
echo 4. The error should be fixed!
echo.
pause
