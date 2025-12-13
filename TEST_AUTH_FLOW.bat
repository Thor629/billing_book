@echo off
echo ========================================
echo Testing Authentication Flow
echo ========================================
echo.

echo Step 1: Checking if backend is running...
curl -s http://localhost:8000/api/health
if %errorlevel% neq 0 (
    echo ERROR: Backend is not running!
    echo Please start backend with: cd backend ^&^& php artisan serve
    pause
    exit /b 1
)
echo Backend is running!
echo.

echo Step 2: Testing login endpoint...
echo Enter email (or press Enter for test@example.com):
set /p email=
if "%email%"=="" set email=test@example.com

echo Enter password (or press Enter for 'password'):
set /p password=
if "%password%"=="" set password=password

echo.
echo Testing login with: %email%
curl -X POST http://localhost:8000/api/auth/login ^
  -H "Content-Type: application/json" ^
  -H "Accept: application/json" ^
  -d "{\"email\":\"%email%\",\"password\":\"%password%\"}"

echo.
echo.
echo ========================================
echo If you see a token above, login works!
echo Copy the token and test organizations:
echo.
echo curl -X GET http://localhost:8000/api/organizations \
echo   -H "Authorization: Bearer YOUR_TOKEN" \
echo   -H "Accept: application/json"
echo ========================================
pause
