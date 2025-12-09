# Sales Return - Troubleshooting Guide

## Current Issue
Sales returns are being created but:
1. ❌ Balance is not decreasing
2. ❌ Transactions not appearing in Cash & Bank

## Root Causes Found

### Issue 1: Status is 'unpaid'
**Database Check:**
```
status: unpaid
amount_paid: 0.00
payment_mode: Card
bank_account_id: null
```

**Why:** The refund only processes when:
- `status` = 'refunded' AND
- `amount_paid` > 0

**Solution:** User must enter an amount in "Amount Paid" field that is >= Total Amount

### Issue 2: Backend Not Restarted
The backend server needs to be restarted to pick up the new code changes in SalesReturnController.

## How to Fix

### Step 1: Restart Backend Server
```bash
# Stop the current backend (Ctrl+C)
# Then restart:
cd backend
php artisan serve
```

### Step 2: Create Sales Return with Refund

**Important Fields:**
1. **Add Items** - Add at least one item
2. **Total Amount** - Will be calculated (e.g., ₹5,000)
3. **Amount Paid** - Enter amount >= Total Amount (e.g., ₹5,000)
4. **Payment Mode** - Select Card or UPI (not Cash if you want to test bank)
5. **Bank Account** - Select a bank account (dropdown will appear)

**Status Logic:**
```dart
// In create_sales_return_screen.dart
final status = amountPaid >= _totalAmount ? 'refunded' : 'unpaid';
```

- If Amount Paid >= Total Amount → status = 'refunded' → Refund processed
- If Amount Paid < Total Amount → status = 'unpaid' → No refund

### Step 3: Verify Results

**Check Database:**
```bash
cd backend
php artisan tinker --execute="print_r(App\Models\SalesReturn::latest()->first(['status', 'amount_paid', 'bank_account_id'])->toArray());"
```

**Expected Output:**
```
Array
(
    [status] => refunded
    [amount_paid] => 5000.00
    [bank_account_id] => 1
)
```

**Check Transactions:**
```bash
php artisan tinker --execute="echo App\Models\BankTransaction::where('transaction_type', 'sales_return')->count();"
```

**Expected:** Should be > 0

## Complete Test Scenario

### Test: Bank Refund
```
1. Restart backend server
2. Open Flutter app
3. Go to Sales → Sales Return
4. Click "Create Sales Return"
5. Fill in:
   - Party: Select customer
   - Add Item: Product A, Qty: 2, Price: ₹2,500
   - Total Amount: ₹5,000 (calculated)
   - Amount Paid: ₹5,000 (IMPORTANT: Must be >= Total)
   - Payment Mode: Card
   - Bank Account: HDFC Bank - ₹1,95,000
6. Click Save

Expected Results:
✅ Sales return created
✅ Status: refunded
✅ Stock increased by 2
✅ HDFC Bank balance: ₹1,95,000 - ₹5,000 = ₹1,90,000
✅ Transaction in Cash & Bank:
   - Type: "Sales Return"
   - Icon: Orange 🔄
   - Amount: -₹5,000
   - Description: "Sales Return Refund: SR-XXX"
```

## Common Mistakes

### Mistake 1: Amount Paid is Empty or Zero
**Problem:** Status becomes 'unpaid', no refund processed
**Solution:** Enter amount >= Total Amount

### Mistake 2: Amount Paid < Total Amount
**Problem:** Status becomes 'unpaid', no refund processed
**Solution:** Enter full amount or more

### Mistake 3: Backend Not Restarted
**Problem:** Old code running, refund logic not executed
**Solution:** Restart backend server

### Mistake 4: Bank Account Not Selected
**Problem:** bank_account_id is null, refund fails
**Solution:** Select payment mode (Card/UPI) and choose bank account

## Backend Code Check

### SalesReturnController.php - Line 164
```php
// Process refund if status is refunded
if ($request->status === 'refunded' && $request->amount_paid > 0) {
    $this->processRefund($request, $organizationId, $salesReturn);
}
```

**This code only runs if:**
1. status = 'refunded'
2. amount_paid > 0

### processRefund() Method
```php
private function processRefund(Request $request, $organizationId, $salesReturn)
{
    $amount = $request->amount_paid;
    $paymentMode = $request->payment_mode ?? 'cash';
    
    if ($paymentMode === 'cash') {
        // Decrease Cash in Hand
        // Create transaction
    } else {
        // Decrease selected bank account
        // Create transaction
    }
}
```

## Verification Checklist

Before creating sales return:
- [ ] Backend server restarted
- [ ] Flutter app restarted (hot reload may not be enough)

When creating sales return:
- [ ] Items added
- [ ] Total amount calculated
- [ ] Amount Paid entered (>= Total Amount)
- [ ] Payment Mode selected (Card/UPI for bank test)
- [ ] Bank Account selected (if not Cash)

After creating sales return:
- [ ] Check database: status should be 'refunded'
- [ ] Check database: amount_paid should be > 0
- [ ] Check database: bank_account_id should not be null
- [ ] Check bank_transactions table: should have new record
- [ ] Check Cash & Bank screen: should show transaction
- [ ] Check bank account balance: should be decreased

## Debug Commands

### Check Latest Sales Return
```bash
php artisan tinker --execute="print_r(App\Models\SalesReturn::latest()->first()->toArray());"
```

### Check Bank Transactions
```bash
php artisan tinker --execute="print_r(App\Models\BankTransaction::where('transaction_type', 'sales_return')->get()->toArray());"
```

### Check Bank Account Balance
```bash
php artisan tinker --execute="print_r(App\Models\BankAccount::find(1)->toArray());"
```

## Summary

The sales return feature is implemented correctly, but requires:
1. ✅ Backend server restart
2. ✅ Amount Paid >= Total Amount (to trigger refund)
3. ✅ Bank Account selection (for bank refunds)

**Status:** Implementation Complete - Requires Proper Testing
**Last Updated:** December 8, 2025
