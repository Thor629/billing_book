# Delivery Challan Troubleshooting Guide

## Issue
Getting "Failed to create delivery challan" error when clicking Save button.

## Steps to Debug

### 1. Check Flutter Console Output

When you click "Save Delivery Challan", look for these debug messages in your Flutter console:

```
DEBUG: Sending delivery challan data: {...}
DEBUG Service: Calling API with data: {...}
DEBUG Service: Response status: XXX
DEBUG Service: Response body: {...}
```

**What to look for:**
- If you DON'T see these messages, the save method isn't being called
- If you see "Response status: 401", you're not authenticated
- If you see "Response status: 422", there's a validation error
- If you see "Response status: 500", there's a server error

### 2. Check Backend Server

Make sure your Laravel backend is running:

```bash
cd backend
php artisan serve
```

Should show: `Server running on [http://127.0.0.1:8000]`

### 3. Test API Directly

Test if the API endpoint exists:

```bash
# In backend directory
php artisan route:list | findstr delivery-challans
```

Should show routes like:
- POST /api/delivery-challans
- GET /api/delivery-challans/next-number

### 4. Check Database Tables

Verify tables exist:

```sql
SHOW TABLES LIKE 'delivery_challans';
SHOW TABLES LIKE 'delivery_challan_items';
```

### 5. Common Issues & Solutions

#### Issue: "Unauthenticated" (401)
**Solution**: Make sure you're logged in and the token is valid

#### Issue: "Validation failed" (422)
**Solution**: Check the response body for which fields are invalid

#### Issue: "Challan number already exists"
**Solution**: Change the challan number to a unique value

#### Issue: "Party not found"
**Solution**: Make sure you've selected a party before saving

#### Issue: "No items"
**Solution**: Add at least one item before saving

### 6. Manual API Test

You can test the API manually using curl:

```bash
curl -X POST http://localhost:8000/api/delivery-challans \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "organization_id": 1,
    "party_id": 1,
    "challan_number": "DC-001",
    "challan_date": "2025-12-08",
    "subtotal": 1000,
    "tax_amount": 180,
    "total_amount": 1180,
    "items": [{
      "item_id": 1,
      "item_name": "Test Item",
      "quantity": 1,
      "price": 1000,
      "discount_percent": 0,
      "tax_percent": 18,
      "amount": 1000
    }]
  }'
```

### 7. Check Laravel Logs

Check for errors in Laravel logs:

```bash
cd backend
type storage\logs\laravel.log
```

Look for recent errors related to delivery challans.

### 8. Enable More Debugging

If still not working, add this to your `.env`:

```
APP_DEBUG=true
LOG_LEVEL=debug
```

Then restart the backend server.

## Quick Fixes

### Fix 1: Clear Cache
```bash
cd backend
php artisan cache:clear
php artisan config:clear
php artisan route:clear
```

### Fix 2: Restart Everything
1. Stop Flutter app (Ctrl+C)
2. Stop backend server (Ctrl+C)
3. Start backend: `php artisan serve`
4. Start Flutter: `flutter run`

### Fix 3: Check Organization
Make sure you have an organization selected. The error might be because `organization_id` is null.

## What to Share for Help

If still not working, share:
1. **Flutter console output** (all DEBUG messages)
2. **Backend server output** (any errors)
3. **Laravel log** (last 20 lines from `storage/logs/laravel.log`)
4. **API response** (from the DEBUG Service messages)

## Expected Behavior

When working correctly, you should see:

```
DEBUG: Sending delivery challan data: {organization_id: 1, party_id: 1, ...}
DEBUG Service: Calling API with data: {organization_id: 1, party_id: 1, ...}
DEBUG Service: Response status: 201
DEBUG Service: Response body: {"message":"Delivery challan created successfully","challan":{...}}
DEBUG: Delivery challan created successfully
```

Then the screen should close and show "Delivery challan created successfully" message.
