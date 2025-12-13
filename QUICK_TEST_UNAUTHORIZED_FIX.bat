@echo off
echo ========================================
echo Quick Test: Unauthorized Error Fix
echo ========================================
echo.

echo This script will help you test the unauthorized error fix.
echo.

echo Step 1: Checking Backend Status...
echo.
curl -s http://localhost:8000/api/health >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Backend is NOT running!
    echo.
    echo Please start the backend first:
    echo   cd backend
    echo   php artisan serve
    echo.
    pause
    exit /b 1
)
echo [OK] Backend is running on http://localhost:8000
echo.

echo Step 2: Running Migration...
echo.
cd backend
php artisan migrate --force
if %errorlevel% neq 0 (
    echo [ERROR] Migration failed!
    pause
    exit /b 1
)
echo [OK] Migration complete
echo.

echo Step 3: Testing Login API...
echo.
echo Testing with default credentials:
echo   Email: test@example.com
echo   Password: password
echo.

curl -X POST http://localhost:8000/api/auth/login ^
  -H "Content-Type: application/json" ^
  -H "Accept: application/json" ^
  -d "{\"email\":\"test@example.com\",\"password\":\"password\"}" ^
  -w "\n\nHTTP Status: %%{http_code}\n"

echo.
echo ========================================
echo Test Results:
echo ========================================
echo.
echo If you see:
echo   - "token": "..." = Login works!
echo   - "expires_at": "..." = Token expiry tracking works!
echo   - HTTP Status: 200 = Success!
echo.
echo If you see HTTP Status: 401 or 422:
echo   - User may not exist
echo   - Run: cd backend ^&^& php artisan db:seed
echo   - Or create user via registration
echo.
echo ========================================
echo Next Steps:
echo ========================================
echo.
echo 1. Start Flutter app: cd flutter_app ^&^& flutter run
echo 2. Login with the same credentials
echo 3. Watch console for these logs:
echo    - "AuthService: Token saved successfully"
echo    - "AuthService: Token expiry saved"
echo    - "ApiClient: Token found and added to headers"
echo    - "OrganizationProvider: Loaded X organizations"
echo.
echo 4. If you see "Unauthorized" error:
echo    - Should show "Session Expired" message
echo    - Should show "Login Again" button
echo    - Click button to re-login
echo.
echo ========================================
pause
