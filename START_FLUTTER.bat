@echo off
echo ========================================
echo Starting Flutter App
echo ========================================
echo.

cd flutter_app

echo Checking dependencies...
if not exist pubspec.lock (
    echo Installing Flutter dependencies...
    call flutter pub get
    echo.
)

echo ========================================
echo Starting Flutter App in Chrome
echo ========================================
echo.
echo Make sure backend is running at:
echo   http://localhost:8000
echo.
echo Login with:
echo   Admin: admin@example.com / password123
echo   User:  john@example.com / password123
echo.
echo ========================================
echo.

call flutter run -d chrome
