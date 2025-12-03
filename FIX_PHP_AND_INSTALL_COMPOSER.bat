@echo off
echo ========================================
echo Fixing PHP Configuration and Installing Composer
echo ========================================
echo.

set PHP_INI=C:\xampp\php\php.ini

echo Step 1: Enabling required PHP extensions...
echo.

REM Check if php.ini exists
if not exist "%PHP_INI%" (
    echo ERROR: php.ini not found at %PHP_INI%
    echo Please check your XAMPP installation.
    pause
    exit /b 1
)

REM Backup php.ini
copy "%PHP_INI%" "%PHP_INI%.backup" >nul
echo ✓ Backed up php.ini to php.ini.backup

REM Enable OpenSSL extension
powershell -Command "(Get-Content '%PHP_INI%') -replace ';extension=openssl', 'extension=openssl' | Set-Content '%PHP_INI%'"
echo ✓ Enabled OpenSSL extension

REM Enable other useful extensions
powershell -Command "(Get-Content '%PHP_INI%') -replace ';extension=mbstring', 'extension=mbstring' | Set-Content '%PHP_INI%'"
powershell -Command "(Get-Content '%PHP_INI%') -replace ';extension=curl', 'extension=curl' | Set-Content '%PHP_INI%'"
powershell -Command "(Get-Content '%PHP_INI%') -replace ';extension=fileinfo', 'extension=fileinfo' | Set-Content '%PHP_INI%'"
powershell -Command "(Get-Content '%PHP_INI%') -replace ';extension=pdo_sqlite', 'extension=pdo_sqlite' | Set-Content '%PHP_INI%'"
powershell -Command "(Get-Content '%PHP_INI%') -replace ';extension=sqlite3', 'extension=sqlite3' | Set-Content '%PHP_INI%'"
echo ✓ Enabled additional extensions (mbstring, curl, fileinfo, sqlite)

echo.
echo Step 2: Downloading Composer installer...
echo.

powershell -Command "Invoke-WebRequest -Uri 'https://getcomposer.org/installer' -OutFile 'composer-setup.php'"

if not exist "composer-setup.php" (
    echo ERROR: Failed to download Composer installer.
    pause
    exit /b 1
)

echo ✓ Downloaded Composer installer

echo.
echo Step 3: Installing Composer...
echo.

php composer-setup.php --install-dir=C:\xampp\php --filename=composer

if %errorlevel% neq 0 (
    echo ERROR: Composer installation failed.
    echo.
    echo Please try:
    echo 1. Restart XAMPP
    echo 2. Run this script again
    echo.
    pause
    exit /b 1
)

echo ✓ Composer installed to C:\xampp\php\composer

REM Clean up
del composer-setup.php

echo.
echo Step 4: Adding Composer to PATH...
echo.

REM Add XAMPP PHP to PATH if not already there
setx PATH "%PATH%;C:\xampp\php" /M >nul 2>&1

echo ✓ Added C:\xampp\php to system PATH

echo.
echo ========================================
echo ✓ SUCCESS!
echo ========================================
echo.
echo Composer has been installed successfully!
echo.
echo IMPORTANT: Please CLOSE this window and open a NEW terminal
echo for the PATH changes to take effect.
echo.
echo Then you can run: COMPLETE_SETUP.bat
echo.
echo Or test Composer with: composer --version
echo.
pause
