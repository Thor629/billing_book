# Sales Invoice Troubleshooting Guide

## Common Issues and Solutions

### Issue 1: "Error loading bank accounts: Exception: Failed to load bank accounts"

**Symptoms:**
- Error message appears at bottom of create invoice screen
- Bank details section doesn't load

**Possible Causes:**
1. Backend server not running
2. Database not set up
3. No bank accounts exist for the user
4. Organization not selected

**Solutions:**

#### Solution 1: Check Backend Server
```bash
# In backend directory
php artisan serve
```
- Server should be running on http://localhost:8000
- Check for any errors in the console

#### Solution 2: Verify Database
```bash
# In backend directory
php artisan migrate
```
- Ensure all migrations have run
- Check if bank_accounts table exists

#### Solution 3: Create a Bank Account
1. Navigate to Cash & Bank screen
2. Click "Add Bank Account"
3. Fill in the details
4. Save the account
5. Return to create invoice screen

#### Solution 4: Select Organization
1. Ensure an organization is selected in the app
2. Check organization dropdown in the header
3. Select an organization if none is selected

---

### Issue 2: "Please select an organization first"

**Symptoms:**
- Message appears when trying to access sales invoices
- Cannot create or view invoices

**Solution:**
1. Click on organization dropdown in header
2. Select an organization from the list
3. If no organizations exist, create one first:
   - Go to Organizations screen
   - Click "Add Organization"
   - Fill in details and save

---

### Issue 3: "No parties found" when clicking Add Party

**Symptoms:**
- Dialog shows "No parties found" message
- Cannot select a party

**Solution:**
1. Navigate to Parties screen
2. Click "Add Party"
3. Create at least one party:
   - Enter party name
   - Enter phone number
   - Select party type (Customer)
   - Save
4. Return to create invoice screen
5. Try adding party again

---

### Issue 4: "No items found" when clicking Add Item

**Symptoms:**
- Dialog shows "No items found" message
- Cannot add items to invoice

**Solution:**
1. Navigate to Items screen
2. Click "Add Item"
3. Create at least one item:
   - Enter item name
   - Enter item code
   - Set selling price
   - Set GST rate
   - Save
4. Return to create invoice screen
5. Try adding item again

---

### Issue 5: Calculations are incorrect

**Symptoms:**
- Totals don't match expected values
- Discount or tax calculations seem wrong

**Verification:**
Check the calculation logic:
```
Subtotal = Quantity × Price per Unit
Discount Amount = Subtotal × (Discount % / 100)
Taxable Amount = Subtotal - Discount Amount
Tax Amount = Taxable Amount × (Tax % / 100)
Line Total = Taxable Amount + Tax Amount

Total Subtotal = Sum of all line subtotals
Total Discount = Sum of all line discounts
Total Tax = Sum of all line taxes
Total Amount = Total Subtotal - Total Discount + Total Tax
```

**Solution:**
1. Verify input values are correct
2. Check that percentages are entered correctly (e.g., 18 for 18%, not 0.18)
3. Ensure quantity and price are positive numbers
4. Refresh the screen and try again

---

### Issue 6: "Invoice number already exists"

**Symptoms:**
- Error when trying to save invoice
- Message says invoice number is duplicate

**Solution:**
1. Change the invoice number to a unique value
2. Or use the auto-increment feature:
   - The system should suggest the next available number
   - Use the suggested number

---

### Issue 7: Backend API returns 400 or 403 error

**Symptoms:**
- API calls fail with 400 Bad Request or 403 Forbidden
- Error messages in console

**Possible Causes:**
1. Missing organization_id parameter
2. User doesn't have access to organization
3. Invalid authentication token

**Solutions:**

#### Check Authentication
```bash
# Test if you're authenticated
curl -X GET "http://localhost:8000/api/user/profile" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

#### Check Organization Access
```bash
# Get your organizations
curl -X GET "http://localhost:8000/api/organizations" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

#### Verify API Call
```bash
# Test sales invoice API
curl -X GET "http://localhost:8000/api/sales-invoices?organization_id=1" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

### Issue 8: Database connection error

**Symptoms:**
- "SQLSTATE[HY000]" errors
- "Connection refused" errors
- Backend crashes

**Solutions:**

#### Check Database Configuration
1. Open `backend/.env` file
2. Verify database settings:
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=your_database_name
DB_USERNAME=your_username
DB_PASSWORD=your_password
```

#### Start Database Server
- **XAMPP:** Start MySQL from XAMPP Control Panel
- **WAMP:** Start MySQL from WAMP Manager
- **Standalone:** `mysql.server start` or `mysqld`

#### Test Connection
```bash
# In backend directory
php artisan db:show
```

---

### Issue 9: Migration errors

**Symptoms:**
- "Table already exists" errors
- "Column not found" errors
- Migration fails

**Solutions:**

#### Fresh Migration (WARNING: Deletes all data)
```bash
# In backend directory
php artisan migrate:fresh
```

#### Rollback and Re-migrate
```bash
# In backend directory
php artisan migrate:rollback
php artisan migrate
```

#### Check Migration Status
```bash
# In backend directory
php artisan migrate:status
```

---

### Issue 10: CORS errors in browser console

**Symptoms:**
- "Access-Control-Allow-Origin" errors
- API calls blocked by browser
- Network errors in console

**Solution:**
1. Check `backend/config/cors.php`
2. Ensure it allows your frontend origin
3. Restart backend server after changes

---

## Debugging Steps

### Step 1: Check Backend Logs
```bash
# In backend directory
tail -f storage/logs/laravel.log
```

### Step 2: Check Flutter Console
- Look for error messages in the Flutter console
- Check for stack traces

### Step 3: Check Network Tab
1. Open browser DevTools (F12)
2. Go to Network tab
3. Look for failed API requests
4. Check request/response details

### Step 4: Test API Directly
Use the provided test script:
```bash
# In backend directory
TEST_SALES_INVOICE_API.bat
```

### Step 5: Verify Database
Use the verification script:
```bash
# In backend directory
VERIFY_AND_FIX_DATABASE.bat
```

---

## Quick Fixes

### Reset Everything (Nuclear Option)
```bash
# Backend
cd backend
php artisan migrate:fresh --seed
php artisan serve

# Flutter
cd flutter_app
flutter clean
flutter pub get
flutter run
```

### Clear Caches
```bash
# Backend
cd backend
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Flutter
cd flutter_app
flutter clean
```

---

## Getting Help

### Information to Provide
When asking for help, provide:
1. Error message (full text)
2. Steps to reproduce
3. Screenshots
4. Backend logs
5. Flutter console output
6. Database type and version
7. Operating system

### Where to Get Help
1. Check this troubleshooting guide
2. Review the documentation files
3. Check the backend logs
4. Search for similar issues online

---

## Prevention Tips

### Before Creating Invoices
1. ✅ Ensure backend is running
2. ✅ Ensure database is set up
3. ✅ Create at least one organization
4. ✅ Create at least one party
5. ✅ Create at least one item
6. ✅ Create at least one bank account (optional)
7. ✅ Select an organization

### Regular Maintenance
1. Keep backend running while using the app
2. Don't modify database directly
3. Use the app's UI for all operations
4. Backup database regularly
5. Keep logs for debugging

---

## Advanced Troubleshooting

### Enable Debug Mode
In `backend/.env`:
```env
APP_DEBUG=true
APP_ENV=local
```

### Check PHP Version
```bash
php -v
# Should be PHP 8.1 or higher
```

### Check Laravel Version
```bash
cd backend
php artisan --version
```

### Check Database Tables
```bash
cd backend
php artisan tinker
>>> DB::select('SHOW TABLES');
```

### Check Specific Table Structure
```bash
cd backend
php artisan tinker
>>> DB::select('DESCRIBE sales_invoices');
```

---

## Still Having Issues?

If none of these solutions work:

1. **Check Prerequisites:**
   - PHP 8.1+ installed
   - Composer installed
   - MySQL/MariaDB running
   - Flutter SDK installed
   - All dependencies installed

2. **Start Fresh:**
   - Delete `backend/vendor` folder
   - Run `composer install`
   - Delete `flutter_app/.dart_tool` folder
   - Run `flutter pub get`
   - Run migrations again
   - Create test data

3. **Verify Each Component:**
   - Test backend API with Postman/cURL
   - Test database connection
   - Test Flutter app separately
   - Check network connectivity

4. **Review Documentation:**
   - SALES_INVOICE_BACKEND_COMPLETE.md
   - SALES_INVOICE_ENHANCEMENT_COMPLETE.md
   - SALES_INVOICE_TESTING_GUIDE.md
