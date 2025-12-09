# Sales Return - Cash & Bank Integration Complete ✅

## Overview
Sales Return feature now fully integrated with Cash & Bank. When a sales return is created with refund:
1. ✅ Stock increases (items returned to inventory)
2. ✅ Cash/Bank balance decreases (refund to customer)
3. ✅ Transaction recorded in Cash & Bank

## Changes Made

### 1. Backend - SalesReturnController.php ✅

**Added Imports:**
```php
use App\Models\Item;
use App\Models\BankAccount;
use App\Models\BankTransaction;
```

**Added Validation:**
- `bank_account_id` field (nullable, for bank refunds)

**Stock Management:**
- When sales return items are created → Stock quantity increases
- Uses `Item::increment('stock_qty', $quantity)`

**Refund Processing:**
- New `processRefund()` method
- Checks if status is 'refunded' and amount_paid > 0
- Decreases Cash in Hand for cash refunds
- Decreases selected bank account for bank refunds
- Creates bank transaction record

### 2. Database Migrations ✅

**Migration 1: Add sales_return to bank_transactions**
- File: `2024_12_08_000002_add_sales_return_to_bank_transactions.php`
- Updated transaction_type ENUM to include 'sales_return'

**Migration 2: Add bank_account_id to sales_returns**
- File: `2024_12_08_000003_add_bank_account_id_to_sales_returns.php`
- Added `bank_account_id` column to sales_returns table
- Foreign key to bank_accounts table

### 3. Model Updates ✅

**SalesReturn.php:**
- Added `bank_account_id` to fillable array
- Added `bankAccount()` relationship method

### 4. Frontend - cash_bank_screen.dart ✅

**Added Transaction Type Display:**
```dart
case 'sales_return':
  icon = Icons.assignment_return;
  amountColor = Colors.orange;
  amountPrefix = '-';
  typeLabel = 'Sales Return';
  break;
```

## How It Works

### Scenario 1: Cash Refund
```
Customer returns items:
- Items: 2 units of Product A
- Refund Amount: ₹2,000
- Payment Mode: Cash
- Status: Refunded

Backend Process:
1. Create sales return record
2. Create sales return items
3. Increase stock: Product A stock += 2
4. Find/Create "Cash in Hand" account
5. Decrease cash balance by ₹2,000
6. Create bank transaction:
   - Type: sales_return
   - Amount: ₹2,000
   - Description: "Sales Return Refund: SR-001"

Result:
✅ Stock increased by 2 units
✅ Cash in Hand decreased by ₹2,000
✅ Transaction in Cash & Bank with orange return icon
```

### Scenario 2: Bank Refund
```
Customer returns items:
- Items: 5 units of Product B
- Refund Amount: ₹10,000
- Payment Mode: Bank Transfer
- Bank Account: HDFC Bank
- Status: Refunded

Backend Process:
1. Create sales return record
2. Create sales return items
3. Increase stock: Product B stock += 5
4. Get selected bank account (HDFC Bank)
5. Decrease bank balance by ₹10,000
6. Create bank transaction:
   - Type: sales_return
   - Amount: ₹10,000
   - Description: "Sales Return Refund: SR-002"

Result:
✅ Stock increased by 5 units
✅ HDFC Bank balance decreased by ₹10,000
✅ Transaction in Cash & Bank with orange return icon
```

### Scenario 3: No Refund (Unpaid)
```
Customer returns items but no refund yet:
- Items: 3 units of Product C
- Status: Unpaid

Backend Process:
1. Create sales return record
2. Create sales return items
3. Increase stock: Product C stock += 3
4. NO balance update (status is unpaid)
5. NO transaction created

Result:
✅ Stock increased by 3 units
❌ No balance change
❌ No transaction in Cash & Bank
```

## API Changes

### Create Sales Return Endpoint
```
POST /api/sales-returns

New Fields:
- bank_account_id (optional): ID of bank account for refund
- status: 'unpaid' or 'refunded'
- amount_paid: Amount to refund

Behavior:
- If status = 'refunded' AND amount_paid > 0:
  → Process refund
  → Update balance
  → Create transaction
- If status = 'unpaid':
  → Only update stock
  → No balance change
```

## Database Schema

### sales_returns Table (Updated)
```sql
ALTER TABLE sales_returns 
ADD COLUMN bank_account_id BIGINT NULL 
AFTER payment_mode;

ADD FOREIGN KEY (bank_account_id) 
REFERENCES bank_accounts(id) 
ON DELETE SET NULL;
```

### bank_transactions Table (Updated)
```sql
ALTER TABLE bank_transactions 
MODIFY COLUMN transaction_type ENUM(
  'add',
  'reduce',
  'transfer_in',
  'transfer_out',
  'expense',
  'payment_in',
  'payment_out',
  'sales_return'  -- NEW
) NOT NULL;
```

## Transaction Types Summary

| Type | Icon | Color | Direction | Trigger |
|------|------|-------|-----------|---------|
| add | ➕ | Green | + | Manual |
| reduce | ➖ | Red | - | Manual |
| expense | 🛒 | Orange | - | Expense |
| payment_in | 💳 | Green | + | Payment In |
| payment_out | 💳 | Red | - | Payment Out |
| **sales_return** | 🔄 | **Orange** | **-** | **Sales Return** |
| transfer_in | ⬇️ | Green | + | Transfer |
| transfer_out | ⬆️ | Red | - | Transfer |

## Testing Guide

### Test 1: Cash Refund
```
1. Create Sales Return:
   - Party: Select customer
   - Items: Add returned items
   - Amount Paid: ₹5,000
   - Payment Mode: Cash
   - Status: Refunded

2. Verify:
   ✅ Sales return created
   ✅ Stock increased for all items
   ✅ Cash in Hand balance decreased by ₹5,000
   ✅ Transaction in Cash & Bank:
      - Type: "Sales Return"
      - Icon: Orange return icon 🔄
      - Amount: -₹5,000
      - Description: "Sales Return Refund: SR-XXX"
```

### Test 2: Bank Refund
```
1. Create Sales Return:
   - Party: Select customer
   - Items: Add returned items
   - Amount Paid: ₹15,000
   - Payment Mode: Bank Transfer
   - Bank Account: Select account
   - Status: Refunded

2. Verify:
   ✅ Sales return created
   ✅ Stock increased for all items
   ✅ Bank balance decreased by ₹15,000
   ✅ Transaction in Cash & Bank with orange icon
```

### Test 3: No Refund
```
1. Create Sales Return:
   - Party: Select customer
   - Items: Add returned items
   - Status: Unpaid

2. Verify:
   ✅ Sales return created
   ✅ Stock increased for all items
   ❌ No balance change
   ❌ No transaction in Cash & Bank
```

## Benefits

### 1. Complete Inventory Tracking
- Returned items automatically added back to stock
- Real-time stock updates
- Accurate inventory levels

### 2. Financial Accuracy
- Refunds automatically deducted from balance
- No manual adjustments needed
- Accurate cash flow tracking

### 3. Complete Audit Trail
- Every refund recorded as transaction
- Easy to track all returns
- Better financial reporting

### 4. Flexible Refund Options
- Cash refunds
- Bank refunds
- Deferred refunds (unpaid status)

## Summary

✅ **Stock Management:** Items returned → Stock increases
✅ **Cash Refunds:** Cash payment mode → Cash in Hand decreases
✅ **Bank Refunds:** Bank payment mode → Selected bank decreases
✅ **Transaction Recording:** All refunds recorded in Cash & Bank
✅ **Visual Display:** Orange return icon in Cash & Bank
✅ **Complete Integration:** Seamless workflow

**Status:** Production Ready
**Last Updated:** December 8, 2025
**Version:** 1.0.0
