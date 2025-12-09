# Sales Return - Bank Account Selection Added ✅

## Issue Fixed
Bank account was not being selected when creating sales return, so refunds were not being processed correctly.

## Changes Made

### 1. Added Bank Account Support to Create Sales Return Screen

**New Imports:**
```dart
import '../../services/bank_account_service.dart';
import '../../models/bank_account_model.dart';
import '../../providers/auth_provider.dart';
```

**New State Variables:**
```dart
final BankAccountService _bankAccountService = BankAccountService();
List<BankAccount> _bankAccounts = [];
int? _selectedBankAccountId;
```

**Load Bank Accounts:**
- Added bank account loading in `_loadInitialData()`
- Fetches all bank accounts for the organization
- Stores in `_bankAccounts` list

**Bank Account Dropdown:**
- Added conditional dropdown (shows only if payment mode is not Cash)
- Displays account name and current balance
- Example: "HDFC Bank - ₹1,95,000"
- Automatically clears selection when Cash is selected

**Send Bank Account ID:**
- Added `bank_account_id` to returnData
- Only included if a bank account is selected
- Sent to backend API

## How It Works Now

### Scenario 1: Cash Refund
```
1. User creates sales return
2. Selects Payment Mode: Cash
3. Bank Account dropdown is hidden
4. Enters Amount Paid: ₹5,000
5. Status automatically set to "refunded" if fully paid

Backend Process:
✅ Stock increases
✅ Cash in Hand balance decreases by ₹5,000
✅ Transaction created with type 'sales_return'
✅ Transaction appears in Cash & Bank
```

### Scenario 2: Bank Refund
```
1. User creates sales return
2. Selects Payment Mode: Card/UPI
3. Bank Account dropdown appears
4. Selects Bank Account: "HDFC Bank - ₹1,95,000"
5. Enters Amount Paid: ₹10,000
6. Status automatically set to "refunded" if fully paid

Backend Process:
✅ Stock increases
✅ HDFC Bank balance decreases by ₹10,000
✅ Transaction created with type 'sales_return'
✅ Transaction appears in Cash & Bank
```

### Scenario 3: Partial Refund (Unpaid)
```
1. User creates sales return
2. Total Amount: ₹10,000
3. Amount Paid: ₹5,000 (less than total)
4. Status automatically set to "unpaid"

Backend Process:
✅ Stock increases
❌ No balance change (status is unpaid)
❌ No transaction created
```

## UI Changes

### Before:
```
Payment Mode: [Cash ▼]
Amount Paid: [Input]
```

### After:
```
Payment Mode: [Cash ▼]

// If Card/UPI selected:
Bank Account: [HDFC Bank - ₹1,95,000 ▼]

Amount Paid: [Input]
```

## Testing Steps

### Test 1: Cash Refund
1. Go to Sales → Sales Return
2. Click "Create Sales Return"
3. Fill in details:
   - Party: Select customer
   - Add items
   - Payment Mode: Cash
   - Amount Paid: ₹5,000
4. Save
5. Check Cash & Bank:
   - Should see transaction
   - Type: "Sales Return"
   - Icon: Orange return icon 🔄
   - Amount: -₹5,000
   - Cash in Hand balance decreased

### Test 2: Bank Refund
1. Create Sales Return
2. Fill in details:
   - Party: Select customer
   - Add items
   - Payment Mode: Card
   - Bank Account: Select account
   - Amount Paid: ₹10,000
3. Save
4. Check Cash & Bank:
   - Should see transaction
   - Type: "Sales Return"
   - Icon: Orange return icon 🔄
   - Amount: -₹10,000
   - Selected bank balance decreased

### Test 3: No Refund
1. Create Sales Return
2. Fill in details:
   - Party: Select customer
   - Add items
   - Amount Paid: Leave empty or less than total
3. Save
4. Check Cash & Bank:
   - No transaction (status is unpaid)
   - Stock still increased

## Status Determination

The status is automatically determined based on amount paid:

```dart
final status = amountPaid >= _totalAmount ? 'refunded' : 'unpaid';
```

- **refunded**: Amount paid >= Total amount → Process refund
- **unpaid**: Amount paid < Total amount → No refund processing

## Summary

✅ **Bank Account Selection Added** - Dropdown shows when payment mode is not Cash
✅ **Balance Display** - Shows current balance for each account
✅ **Automatic Clearing** - Bank account cleared when Cash is selected
✅ **Backend Integration** - bank_account_id sent to API
✅ **Refund Processing** - Backend decreases correct account balance
✅ **Transaction Recording** - Creates bank_transactions record
✅ **Cash & Bank Display** - Shows sales return transactions

**Status:** Ready to Test
**Last Updated:** December 8, 2025

---

**Now try creating a sales return with a bank refund and check Cash & Bank!**
