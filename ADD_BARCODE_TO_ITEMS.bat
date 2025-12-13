@echo off
echo ========================================
echo Adding Barcode Column to Items Table
echo ========================================
echo.

cd backend

echo Running migration...
php artisan migrate --path=database/migrations/2024_01_15_000001_add_barcode_to_items_table.php

echo.
echo ========================================
echo Migration Complete!
echo ========================================
echo.
echo The barcode column has been added to the items table.
echo You can now use barcode scanning in POS Billing.
echo.
pause
