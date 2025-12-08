@echo off
echo ========================================
echo Sales Invoice API Testing
echo ========================================
echo.

echo This script will test the Sales Invoice API endpoints.
echo Make sure the backend server is running (php artisan serve)
echo.

set /p TOKEN="Enter your Bearer Token: "
set /p ORG_ID="Enter Organization ID (default: 1): "
if "%ORG_ID%"=="" set ORG_ID=1

echo.
echo Testing with Organization ID: %ORG_ID%
echo.

echo ========================================
echo Test 1: Get Sales Invoices
echo ========================================
curl -X GET "http://localhost:8000/api/sales-invoices?organization_id=%ORG_ID%" ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "Accept: application/json"
echo.
echo.

echo ========================================
echo Test 2: Get Next Invoice Number
echo ========================================
curl -X GET "http://localhost:8000/api/sales-invoices/next-number?organization_id=%ORG_ID%&prefix=SHI" ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "Accept: application/json"
echo.
echo.

echo ========================================
echo Test 3: Create Sample Invoice (Optional)
echo ========================================
set /p CREATE="Do you want to create a test invoice? (y/n): "
if /i "%CREATE%"=="y" (
    set /p PARTY_ID="Enter Party ID: "
    set /p ITEM_ID="Enter Item ID: "
    
    curl -X POST "http://localhost:8000/api/sales-invoices" ^
      -H "Authorization: Bearer %TOKEN%" ^
      -H "Content-Type: application/json" ^
      -H "Accept: application/json" ^
      -d "{\"organization_id\":%ORG_ID%,\"party_id\":%PARTY_ID%,\"invoice_prefix\":\"TEST\",\"invoice_number\":\"001\",\"invoice_date\":\"2025-01-04\",\"payment_terms\":30,\"due_date\":\"2025-02-03\",\"items\":[{\"item_id\":%ITEM_ID%,\"item_name\":\"Test Item\",\"quantity\":1,\"unit\":\"pcs\",\"price_per_unit\":100,\"discount_percent\":0,\"tax_percent\":18}]}"
    echo.
    echo.
)

echo ========================================
echo Testing Complete!
echo ========================================
echo.
pause
