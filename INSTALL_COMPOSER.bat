@echo off
echo ========================================
echo Composer Installation Script
echo ========================================
echo.

REM Check if composer is already installed
where composer >nul 2>nul
if %errorlevel% equ 0 (
    echo Composer is already installed!
    composer --version
    echo.
    echo If you want to reinstall, please uninstall first.
    pause
    exit /b 0
)

echo Downloading Composer installer...
echo.

REM Create temp directory
if not exist "%TEMP%\composer_install" mkdir "%TEMP%\composer_install"
cd /d "%TEMP%\composer_install"

REM Download Composer installer
powershell -Command "& {Invoke-WebRequest -Uri 'https://getcomposer.org/installer' -OutFile 'composer-setup.php'}"

if not exist "composer-setup.php" (
    echo ERROR: Failed to download Composer installer.
    echo Please download manually from: https://getcomposer.org/download/
    pause
    exit /b 1
)

echo.
echo Installing Composer...
echo.

REM Install Composer globally
php composer-setup.php --install-dir="%ProgramFiles%\Composer" --filename=composer.bat

if %errorlevel% neq 0 (
    echo.
    echo ERROR: Installation failed.
    echo.
    echo Please try manual installation:
    echo 1. Download from: https://getcomposer.org/Composer-Setup.exe
    echo 2. Run the installer
    echo 3. Follow the installation wizard
    echo.
    pause
    exit /b 1
)

REM Add to PATH if not already there
setx PATH "%PATH%;%ProgramFiles%\Composer" /M

echo.
echo ========================================
echo SUCCESS! Composer installed!
echo ========================================
echo.
echo Please CLOSE this window and open a NEW terminal window
echo for the PATH changes to take effect.
echo.
echo Then run: SETUP_DATABASE.bat
echo.
pause
