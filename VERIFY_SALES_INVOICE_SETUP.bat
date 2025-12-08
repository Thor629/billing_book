@echo off
color 0A
echo ========================================
echo Sales Invoice Setup Verification
echo ========================================
echo.

set ERROR_COUNT=0

echo [1/10] Checking if backend directory exists...
if exist "backend\" (
    echo [OK] Backend directory found
) else (
    echo [ERROR] Backend directory not found!
    set /a ERROR_COUNT+=1
)
echo.

echo [2/10] Checking if Flutter app directory exists...
if exist "flutter_app\" (
    echo [OK] Flutter app directory found
) else (
    echo [ERROR] Flutter app directory not found!
    set /a ERROR_COUNT+=1
)
echo.

echo [3/10] Checking PHP installation...
php -v >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] PHP is installed
    php -v | findstr "PHP"
) else (
    echo [ERROR] PHP is not installed or not in PATH!
    set /a ERROR_COUNT+=1
)
echo.

echo [4/10] Checking Composer installation...
composer --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Composer is installed
    composer --version | findstr "Composer"
) else (
    echo [ERROR] Composer is not installed or not in PATH!
    set /a ERROR_COUNT+=1
)
echo.

echo [5/10] Checking Flutter installation...
flutter --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Flutter is installed
    flutter --version | findstr "Flutter"
) else (
    echo [ERROR] Flutter is not installed or not in PATH!
    set /a ERROR_COUNT+=1
)
echo.

echo [6/10] Checking backend .env file...
if exist "backend\.env" (
    echo [OK] Backend .env file exists
) else (
    echo [WARNING] Backend .env file not found!
    echo Creating from .env.example...
    if exist "backend\.env.example" (
        copy "backend\.env.example" "backend\.env" >nul
        echo [OK] Created .env file from example
        echo [ACTION REQUIRED] Please configure database settings in backend\.env
    ) else (
        echo [ERROR] .env.example not found!
        set /a ERROR_COUNT+=1
    )
)
echo.

echo [7/10] Checking backend vendor directory...
if exist "backend\vendor\" (
    echo [OK] Backend dependencies installed
) else (
    echo [WARNING] Backend dependencies not installed
    echo [ACTION REQUIRED] Run: cd backend ^&^& composer install
    set /a ERROR_COUNT+=1
)
echo.

echo [8/10] Checking SalesInvoiceController...
if exist "backend\app\Http\Controllers\SalesInvoiceController.php" (
    echo [OK] SalesInvoiceController exists
) else (
    echo [ERROR] SalesInvoiceController not found!
    set /a ERROR_COUNT+=1
)
echo.

echo [9/10] Checking sales invoice migration...
if exist "backend\database\migrations\2024_12_03_000004_create_sales_invoices_table.php" (
    echo [OK] Sales invoice migration exists
) else (
    echo [ERROR] Sales invoice migration not found!
    set /a ERROR_COUNT+=1
)
echo.

echo [10/10] Checking Flutter sales invoice screen...
if exist "flutter_app\lib\screens\user\create_sales_invoice_screen.dart" (
    echo [OK] Create sales invoice screen exists
) else (
    echo [ERROR] Create sales invoice screen not found!
    set /a ERROR_COUNT+=1
)
echo.

echo ========================================
echo Verification Summary
echo ========================================
echo.

if %ERROR_COUNT% equ 0 (
    color 0A
    echo [SUCCESS] All checks passed!
    echo.
    echo Your setup is ready for sales invoice functionality.
    echo.
    echo Next steps:
    echo 1. Start backend: cd backend ^&^& php artisan serve
    echo 2. Run migrations: cd backend ^&^& php artisan migrate
    echo 3. Start Flutter: cd flutter_app ^&^& flutter run
) else (
    color 0C
    echo [FAILED] %ERROR_COUNT% error(s) found!
    echo.
    echo Please fix the errors above before proceeding.
    echo.
    echo Common fixes:
    echo - Install PHP: https://www.php.net/downloads
    echo - Install Composer: https://getcomposer.org/download/
    echo - Install Flutter: https://flutter.dev/docs/get-started/install
    echo - Run: cd backend ^&^& composer install
    echo - Configure: backend\.env file
)
echo.
echo ========================================
pause
