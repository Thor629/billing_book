@echo off
echo ========================================
echo SaaS Billing Platform - Complete Setup
echo ========================================
echo.

REM Check if PHP is installed
where php >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: PHP is not installed or not in PATH.
    echo.
    echo Please install PHP 8.1 or higher from:
    echo https://windows.php.net/download/
    echo.
    echo Or install XAMPP which includes PHP:
    echo https://www.apachefriends.org/download.html
    echo.
    pause
    exit /b 1
)

echo ✓ PHP found:
php --version | findstr /C:"PHP"
echo.

REM Check if Composer is installed
where composer >nul 2>nul
if %errorlevel% neq 0 (
    echo ✗ Composer not found
    echo.
    echo Composer is required to install Laravel dependencies.
    echo.
    echo Please choose an option:
    echo   1. Download Composer installer (opens browser)
    echo   2. Try automatic installation (requires admin rights)
    echo   3. Exit and install manually
    echo.
    choice /C 123 /N /M "Enter your choice (1, 2, or 3): "
    
    if errorlevel 3 (
        echo.
        echo Please install Composer from: https://getcomposer.org/download/
        echo Then run this script again.
        pause
        exit /b 1
    )
    
    if errorlevel 2 (
        echo.
        echo Attempting automatic installation...
        echo This requires administrator privileges.
        echo.
        pause
        
        REM Try to download and install
        powershell -Command "Start-Process powershell -Verb RunAs -ArgumentList '-Command', 'Invoke-WebRequest -Uri https://getcomposer.org/installer -OutFile $env:TEMP\composer-setup.php; php $env:TEMP\composer-setup.php --install-dir=C:\ProgramData\ComposerSetup --filename=composer; [Environment]::SetEnvironmentVariable(\"Path\", $env:Path + \";C:\ProgramData\ComposerSetup\", \"Machine\")'"
        
        echo.
        echo If installation succeeded, please CLOSE this window
        echo and open a NEW terminal, then run this script again.
        pause
        exit /b 0
    )
    
    if errorlevel 1 (
        start https://getcomposer.org/Composer-Setup.exe
        echo.
        echo Browser opened with Composer installer.
        echo Please install Composer and run this script again.
        pause
        exit /b 0
    )
)

echo ✓ Composer found:
composer --version | findstr /C:"Composer"
echo.

echo ========================================
echo Starting Laravel Setup...
echo ========================================
echo.

cd backend

echo Step 1: Installing Composer dependencies...
echo (This may take a few minutes)
echo.
composer install --no-interaction
if %errorlevel% neq 0 (
    echo ERROR: Composer install failed.
    pause
    exit /b 1
)
echo ✓ Dependencies installed
echo.

echo Step 2: Generating application key...
php artisan key:generate --force
if %errorlevel% neq 0 (
    echo ERROR: Failed to generate app key.
    pause
    exit /b 1
)
echo ✓ Application key generated
echo.

echo Step 3: Setting up database...
php artisan migrate:fresh --seed --force
if %errorlevel% neq 0 (
    echo ERROR: Database migration failed.
    pause
    exit /b 1
)
echo ✓ Database created and seeded
echo.

cd ..

echo ========================================
echo ✓ SETUP COMPLETE!
echo ========================================
echo.
echo Database: backend\database\database.sqlite
echo.
echo Test Credentials:
echo   Admin: admin@example.com / password
echo   User:  user@example.com / password
echo.
echo Next Steps:
echo   1. Run: START_BACKEND.bat (to start Laravel API)
echo   2. Run: START_FLUTTER.bat (to start Flutter app)
echo.
echo API will be at: http://localhost:8000
echo.
pause
