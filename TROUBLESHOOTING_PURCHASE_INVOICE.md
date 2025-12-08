# Troubleshooting Purchase Invoice Save Error

## Current Status
- ✅ Database migration completed successfully
- ✅ Model updated with all required fields
- ✅ Controller validation rules are correct
- ✅ Routes are configured properly
- ⏳ Still getting error when saving

## Changes Made

### 1. Enhanced Error Reporting
Updated `PurchaseInvoiceService` to show detailed error messages including:
- HTTP status code
- Error message from backend
- Validation errors (if any)
- Raw response body (if JSON parsing fails)

### 2. Cleared Laravel Caches
```bash
php artisan route:clear
php artisan config:clear
```

## Next Steps to Debug

### Step 1: Try Saving Again
With the enhanced error reporting, try creating a purchase invoice again. The error message should now show:
- Specific validation errors
- HTTP status code
- Detailed error message

### Step 2: Check Backend Logs
If error persists, check:
```bash
cd backend
Get-Content storage/logs/laravel.log -Tail 100
```

### Step 3: Test API Directly
Test the API endpoint directly using a tool like Postman or curl:

```bash
curl -X POST http://localhost:8000/api/purchase-invoices \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "organization_id": 1,
    "party_id": 1,
    "invoice_number": "TEST-001",
    "invoice_date": "2024-12-06",
    "payment_terms": 30,
    "due_date": "2025-01-05",
    "subtotal": 1000,
    "discount_amount": 0,
    "tax_amount": 180,
    "additional_charges": 0,
    "total_amount": 1180,
    "amount_paid": 0,
    "items": [
      {
        "item_id": 1,
        "quantity": 2,
        "price_per_unit": 500,
        "discount_percent": 0,
        "tax_percent": 18
      }
    ]
  }'
```

## Common Issues & Solutions

### Issue 1: Validation Errors
**Symptoms:** Error mentions specific fields

**Solutions:**
- Check all required fields are being sent
- Verify data types match validation rules
- Ensure foreign keys exist (organization_id, party_id, item_id)

### Issue 2: Authentication Error
**Symptoms:** 401 Unauthorized or 403 Forbidden

**Solutions:**
- Check auth token is valid
- Verify user has access to organization
- Ensure token is being sent in headers

### Issue 3: Database Constraint Error
**Symptoms:** SQL error or foreign key constraint

**Solutions:**
- Verify migration ran successfully
- Check all foreign key references exist
- Ensure unique constraints aren't violated

### Issue 4: Missing Fields
**Symptoms:** "Field X is required" or "Unknown column"

**Solutions:**
- Run migrations: `php artisan migrate`
- Check model fillable array
- Verify database schema matches model

## Validation Rules

The backend expects these fields:

### Required Fields
- `organization_id` (integer, must exist in organizations table)
- `party_id` (integer, must exist in parties table)
- `invoice_number` (string)
- `invoice_date` (date format: YYYY-MM-DD)
- `payment_terms` (integer, min: 0)
- `due_date` (date format: YYYY-MM-DD)
- `items` (array, min 1 item)
  - `item_id` (integer, must exist in items table)
  - `quantity` (numeric, min: 0.001)
  - `price_per_unit` (numeric, min: 0)

### Optional Fields
- `discount_amount` (numeric, min: 0)
- `additional_charges` (numeric, min: 0)
- `bank_account_id` (integer, must exist if provided)
- `amount_paid` (numeric, min: 0)
- `notes` (string)
- `terms_conditions` (string)
- `items.*.discount_percent` (numeric, 0-100)
- `items.*.tax_percent` (numeric, 0-100)

## Debug Checklist

- [ ] Migration ran successfully
- [ ] Model has all fields in fillable array
- [ ] Database table has all columns
- [ ] Routes are accessible
- [ ] Auth token is valid
- [ ] Organization exists and user has access
- [ ] Party (vendor) exists
- [ ] Items exist in database
- [ ] All required fields are being sent
- [ ] Data types match validation rules
- [ ] Laravel caches are cleared

## Files to Check

1. **Model:** `backend/app/Models/PurchaseInvoice.php`
2. **Controller:** `backend/app/Http/Controllers/PurchaseInvoiceController.php`
3. **Migration:** `backend/database/migrations/2025_12_06_115227_add_missing_fields_to_purchase_invoices_table.php`
4. **Service:** `flutter_app/lib/services/purchase_invoice_service.dart`
5. **Screen:** `flutter_app/lib/screens/user/create_purchase_invoice_screen.dart`

## Expected Behavior

### Success Response (201)
```json
{
  "message": "Purchase invoice created successfully",
  "invoice": {
    "id": 1,
    "organization_id": 1,
    "party_id": 1,
    "invoice_number": "1",
    "total_amount": 1180.00,
    "payment_status": "unpaid",
    ...
  }
}
```

### Error Response (422)
```json
{
  "message": "The given data was invalid.",
  "errors": {
    "party_id": ["The party id field is required."],
    "items": ["The items field must have at least 1 items."]
  }
}
```

## Next Action

**Please try saving a purchase invoice again and share the new error message.** 

The enhanced error reporting should now show exactly what's failing, which will help us fix the issue quickly.
