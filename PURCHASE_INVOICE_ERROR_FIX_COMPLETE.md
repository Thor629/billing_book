# Purchase Invoice Error Fix - Complete

## Problem
When creating a purchase invoice with payment, the system was throwing an error:
```
SQLSTATE[23000]: Integrity constraint violation: 19 CHECK constraint failed: transaction_type
```

## Root Cause
The `PurchaseInvoiceController` was using an invalid transaction type value when creating bank transactions:
- **Incorrect value**: `'subtract'`
- **Valid values**: `'add'`, `'reduce'`, `'transfer_out'`, `'transfer_in'`

## Solution
Changed the transaction type from `'subtract'` to `'reduce'` in the bank transaction creation code.

### File Modified
`backend/app/Http/Controllers/PurchaseInvoiceController.php`

### Change Made
```php
// Before (INCORRECT):
'transaction_type' => 'subtract',

// After (CORRECT):
'transaction_type' => 'reduce',
```

## Why 'reduce'?
For purchase invoice payments:
- Money is going OUT of the bank account (paying a vendor)
- This reduces the bank balance
- Therefore, `'reduce'` is the correct transaction type

## Transaction Type Reference
Based on `backend/database/migrations/2024_12_04_000002_create_bank_transactions_table.php`:

| Transaction Type | Use Case |
|-----------------|----------|
| `add` | Money coming into the account (e.g., sales invoice payment received) |
| `reduce` | Money going out of the account (e.g., purchase invoice payment made) |
| `transfer_out` | Money transferred to another bank account (outgoing) |
| `transfer_in` | Money transferred from another bank account (incoming) |

## Testing
After this fix, purchase invoices can be created successfully with payment, and the bank transaction is recorded correctly with the `'reduce'` transaction type.

## Status
✅ **FIXED** - Purchase invoice creation with payment now works correctly.
