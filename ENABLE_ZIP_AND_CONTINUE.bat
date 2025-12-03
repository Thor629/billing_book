@echo off
echo ========================================
echo Enabling ZIP Extension
echo ========================================
echo.

set PHP_INI=C:\xampp\php\php.ini

REM Backup php.ini
copy "%PHP_INI%" "%PHP_INI%.backup_%date:~-4,4%%date:~-10,2%%date:~-7,2%" >nul 2>&1

REM Enable ZIP extension
powershell -Command "(Get-Content '%PHP_INI%') -replace ';extension=zip', 'extension=zip' | Set-Content '%PHP_INI%'"

echo ✓ ZIP extension enabled
echo.
echo Please restart XAMPP if it's running, then run:
echo   SETUP_WITH_XAMPP.bat
echo.
pause
