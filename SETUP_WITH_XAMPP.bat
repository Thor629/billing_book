@echo off
echo ========================================
echo SaaS Billing Platform - Setup with XAMPP
echo ========================================
echo.

set PHP_PATH=C:\xampp\php\php.exe
set COMPOSER_PATH=C:\xampp\php\composer

REM Check if PHP exists
if not exist "%PHP_PATH%" (
    echo ERROR: PHP not found at %PHP_PATH%
    echo Please check your XAMPP installation.
    pause
    exit /b 1
)

echo ✓ PHP found at %PHP_PATH%
"%PHP_PATH%" --version | findstr /C:"PHP"
echo.

REM Check if Composer exists
if not exist "%COMPOSER_PATH%" (
    echo Composer not found. Installing...
    echo.
    
    REM Download Composer installer
    powershell -Command "Invoke-WebRequest -Uri 'https://getcomposer.org/installer' -OutFile 'composer-setup.php'"
    
    if not exist "composer-setup.php" (
        echo ERROR: Failed to download Composer installer.
        pause
        exit /b 1
    )
    
    REM Install Composer (skip OpenSSL check for now)
    "%PHP_PATH%" composer-setup.php --install-dir=C:\xampp\php --filename=composer --disable-tls --no-check-certificate
    
    if %errorlevel% neq 0 (
        echo ERROR: Composer installation failed.
        echo Please run: FIX_PHP_AND_INSTALL_COMPOSER.bat
        pause
        exit /b 1
    )
    
    del composer-setup.php
    echo ✓ Composer installed
    echo.
)

echo ✓ Composer found
"%PHP_PATH%" "%COMPOSER_PATH%" --version
echo.

echo ========================================
echo Starting Laravel Setup...
echo ========================================
echo.

cd backend

echo Step 1: Installing Composer dependencies...
echo (This may take a few minutes)
echo.
"%PHP_PATH%" "%COMPOSER_PATH%" install --no-interaction --ignore-platform-reqs
if %errorlevel% neq 0 (
    echo ERROR: Composer install failed.
    pause
    exit /b 1
)
echo ✓ Dependencies installed
echo.

echo Step 2: Generating application key...
"%PHP_PATH%" artisan key:generate --force
if %errorlevel% neq 0 (
    echo ERROR: Failed to generate app key.
    pause
    exit /b 1
)
echo ✓ Application key generated
echo.

echo Step 3: Setting up database...
"%PHP_PATH%" artisan migrate:fresh --seed --force
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
echo To start the backend server, run:
echo   cd backend
echo   C:\xampp\php\php.exe artisan serve
echo.
echo Or use: START_BACKEND.bat
echo.
pause
