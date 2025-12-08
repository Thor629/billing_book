@echo off
echo ========================================
echo Sales Invoice Database Verification
echo ========================================
echo.

echo Step 1: Checking database connection...
php artisan db:show
if %errorlevel% neq 0 (
    echo ERROR: Cannot connect to database!
    echo Please check your .env file configuration.
    pause
    exit /b 1
)
echo Database connection OK!
echo.

echo Step 2: Running migrations...
php artisan migrate --force
if %errorlevel% neq 0 (
    echo ERROR: Migration failed!
    pause
    exit /b 1
)
echo Migrations completed successfully!
echo.

echo Step 3: Verifying sales_invoices table...
php artisan tinker --execute="echo 'Tables: '; print_r(DB::select('SHOW TABLES'));"
echo.

echo Step 4: Checking sales_invoices table structure...
php artisan tinker --execute="echo 'Sales Invoices Columns: '; print_r(DB::select('DESCRIBE sales_invoices'));"
echo.

echo Step 5: Checking sales_invoice_items table structure...
php artisan tinker --execute="echo 'Sales Invoice Items Columns: '; print_r(DB::select('DESCRIBE sales_invoice_items'));"
echo.

echo ========================================
echo Verification Complete!
echo ========================================
echo.
echo If you see the tables and columns above, your database is ready!
echo.
pause
