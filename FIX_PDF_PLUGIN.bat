@echo off
echo ========================================
echo Fixing PDF Plugin Issue
echo ========================================
echo.

cd flutter_app

echo [1/4] Cleaning Flutter project...
flutter clean
echo.

echo [2/4] Getting dependencies...
flutter pub get
echo.

echo [3/4] Running Flutter doctor...
flutter doctor
echo.

echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo IMPORTANT: You MUST do a FULL RESTART
echo.
echo Steps:
echo 1. STOP the current Flutter app (Ctrl+C or 'q')
echo 2. Run: flutter run
echo 3. DO NOT use hot restart (R)
echo 4. Wait for full app rebuild
echo.
echo The plugin needs a full restart to register properly.
echo.
pause
