@echo off
echo Testing Payment Out Next Number API...
echo.

REM Get the current payment numbers from database
echo Current payment numbers in database:
cd backend
php artisan tinker --execute="echo PaymentOut::pluck('payment_number')->toJson();"
echo.

echo.
echo Check the Flutter console and backend logs for debug output
echo Backend logs: backend\storage\logs\laravel.log
pause
