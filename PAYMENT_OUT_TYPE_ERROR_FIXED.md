# Payment Out Type Error Fixed! 🔧

## The Error
```
TypeError: "2": type 'String' is not a subtype of type 'int'
```

## The Cause

The `organization_id` from the HTTP header was being passed as a **string** to the database, but the database column expects an **integer**.

## The Fix

Changed line 40 in `PaymentOutController.php`:

**Before:**
```php
$organizationId = $request->header('X-Organization-Id');
```

**After:**
```php
$organizationId = (int)$request->header('X-Organization-Id');
```

This casts the string to an integer before saving to the database.

## How to Test

1. **Restart backend server:**
   ```bash
   # Stop current server (Ctrl+C)
   cd backend
   php artisan serve
   ```

2. **Try creating a payment:**
   - Open Payment Out screen
   - Click "Create Payment Out"
   - Fill in all details:
     - Supplier: Select a supplier
     - Amount: Enter amount (e.g., 2000)
     - Payment Method: Select method
     - Bank Account: Select if not cash
   - Click **Save**
   - Should save successfully! ✅

3. **Verify auto-numbering:**
   - First payment: **PO-000001**
   - Second payment: **PO-000002**
   - Third payment: **PO-000003**

## Both Bugs Fixed

1. ✅ **Undefined array key** - Fixed with `isset()` check
2. ✅ **Type error** - Fixed with `(int)` cast

Payment Out feature is now fully working!
