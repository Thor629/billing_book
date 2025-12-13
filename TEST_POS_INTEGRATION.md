# Quick Test - POS Integration (2 Minutes)

## ✅ Test Both Requirements

1. **POS bills show in Sales Invoice with party "POS"**
2. **Stock reduces when POS bill is saved**

## Test Steps

### Step 1: Check Initial Stock (30 seconds)
1. Open **POS Billing** screen
2. Search for any item (type 2+ characters)
3. **Note the stock quantity** (e.g., "Stock: 50")
4. Remember the item name

### Step 2: Create POS Bill (30 seconds)
1. Click on the item to add it
2. Change quantity to **2** (click + button)
3. Enter received amount: **500**
4. Click **"Save Bill [F7]"**
5. **Note the invoice number** (e.g., "POS-000001")
6. Success message should appear

### Step 3: Verify Stock Reduced (30 seconds) ✅ REQUIREMENT 2
1. Search for the same item again
2. **Check stock quantity**
3. **Expected**: Stock reduced by 2
   - Was: 50
   - Now: 48 ✅

### Step 4: Verify in Sales Invoice (30 seconds) ✅ REQUIREMENT 1
1. Navigate to **"Sales Invoices"** screen
2. Look for your invoice (POS-000001)
3. **Check party column**
4. **Expected**: Shows "POS" ✅
5. **Expected**: Status shows "Paid" (green)

## Expected Results

### ✅ Requirement 1: Party Name Shows "POS"
```
Sales Invoice Screen:
┌──────────────┬────────┬────────────┬──────────┬────────┐
│ Invoice #    │ Party  │ Date       │ Amount   │ Status │
├──────────────┼────────┼────────────┼──────────┼────────┤
│ POS-000001   │ POS ✅ │ 13 Jan 25  │ ₹236.00  │ Paid   │
└──────────────┴────────┴────────────┴──────────┴────────┘
```

### ✅ Requirement 2: Stock Quantity Reduced
```
Before:  Item A - Stock: 50
Sold:    2 quantity
After:   Item A - Stock: 48 ✅
```

## Success Indicators

- ✅ Stock quantity decreased by exact amount sold
- ✅ Party column shows "POS" (not "N/A")
- ✅ Invoice appears in sales invoice list
- ✅ Payment status shows "Paid"
- ✅ Invoice number format: POS-XXXXXX

## If Something Doesn't Work

### Stock Not Reducing?
- Check backend logs: `backend/storage/logs/laravel.log`
- Verify backend server is running
- Try refreshing POS screen

### "POS" Not Showing?
- Refresh sales invoice screen (F5)
- Check date filter includes today
- Verify organization selected

### Invoice Not Appearing?
- Wait 2-3 seconds and refresh
- Check backend server running
- Verify no errors in console

## Quick Verification Commands

### Check Stock in Database:
```bash
cd backend
php artisan tinker --execute="DB::table('items')->where('id', 1)->value('stock_qty')"
```

### Check POS Invoices:
```bash
php artisan tinker --execute="DB::table('sales_invoices')->where('invoice_number', 'like', 'POS-%')->count()"
```

## Test Multiple Times

Try creating 3 POS bills:

1. **Bill 1**: Item A (2 qty) → Stock: 50 → 48
2. **Bill 2**: Item A (3 qty) → Stock: 48 → 45
3. **Bill 3**: Item B (1 qty) → Stock: 30 → 29

**Verify**:
- All 3 show in Sales Invoice with party "POS"
- Stock quantities correct for both items

## Complete Test Checklist

- [ ] Stock quantity before noted
- [ ] POS bill created successfully
- [ ] Invoice number received
- [ ] Stock quantity reduced correctly
- [ ] Invoice appears in Sales Invoice screen
- [ ] Party shows as "POS"
- [ ] Payment status shows "Paid"
- [ ] Can view invoice details
- [ ] Multiple bills work correctly

## Time Required

- **Single Test**: 2 minutes
- **Complete Test**: 5 minutes
- **Multiple Bills**: 10 minutes

## Success!

If all checks pass, your POS integration is **100% working**! 🎉

Both requirements completed:
1. ✅ POS bills show with party "POS"
2. ✅ Stock reduces automatically

---

**Ready to Test**: ✅ YES
**Difficulty**: Easy
**Time**: 2 minutes
