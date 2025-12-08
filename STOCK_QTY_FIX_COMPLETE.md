# Stock Quantity Display Fix - Complete

## Problem
Items were showing "0 pcs" in the stock column even though they had opening stock values set. This was because:
- `opening_stock` field contained the initial stock value (e.g., 100)
- `stock_qty` field was set to 0 by default
- The UI displays `stock_qty`, not `opening_stock`

## Root Cause
When items were created, the `stock_qty` field was not being initialized with the `opening_stock` value. The database default for `stock_qty` is 0, so new items showed 0 stock even though they had opening stock defined.

## Solution Implemented

### 1. Backend Fix - ItemController
Updated the `store()` method to automatically set `stock_qty` from `opening_stock` when creating new items:

```php
// If stock_qty is not provided but opening_stock is, use opening_stock as initial stock_qty
if (!isset($validated['stock_qty']) && isset($validated['opening_stock'])) {
    $validated['stock_qty'] = (int) $validated['opening_stock'];
}
```

**File Modified:** `backend/app/Http/Controllers/ItemController.php`

### 2. Database Migration
Created a migration to fix existing items in the database:

```php
// Update all items where stock_qty is 0 but opening_stock is greater than 0
DB::statement('UPDATE items SET stock_qty = CAST(opening_stock AS INTEGER) WHERE stock_qty = 0 AND opening_stock > 0');
```

**File Created:** `backend/database/migrations/2025_12_06_112424_update_items_stock_qty_from_opening_stock.php`

## How It Works

### Before Fix
```
Item Creation:
- User enters opening_stock = 100
- stock_qty defaults to 0
- UI shows "0 pcs" ❌
```

### After Fix
```
Item Creation:
- User enters opening_stock = 100
- stock_qty automatically set to 100
- UI shows "100 pcs" ✅
```

## Stock Management Flow

### New Items (After Fix)
1. User creates item with opening_stock = 100
2. Backend sets stock_qty = 100 automatically
3. Item displays correctly in UI

### Sales Invoice
1. User creates sales invoice selling 10 units
2. Backend reduces stock_qty by 10 (now 90)
3. opening_stock remains 100 (historical record)
4. UI shows "90 pcs"

### Stock Restoration
1. User deletes sales invoice
2. Backend restores stock_qty by 10 (back to 100)
3. UI shows "100 pcs"

## Field Definitions

### `opening_stock` (DECIMAL)
- **Purpose:** Historical record of initial stock when item was created
- **Never changes:** Remains constant as a reference point
- **Used for:** Reporting, auditing, stock reconciliation

### `stock_qty` (INTEGER)
- **Purpose:** Current available stock quantity
- **Changes:** Increases/decreases with purchases/sales
- **Used for:** Display in UI, sales validation, inventory management

## Testing

### Test 1: Create New Item
1. Go to Items screen
2. Click "Create Item"
3. Enter item details with opening_stock = 50
4. Save item
5. ✅ Item should show "50 pcs" in stock column

### Test 2: Existing Items Fixed
1. Go to Items screen
2. Check items that previously showed "0 pcs"
3. ✅ Should now show correct stock from opening_stock

### Test 3: Sales Reduces Stock
1. Create sales invoice with 10 units of an item
2. Check Items screen
3. ✅ Stock should be reduced by 10

### Test 4: Opening Stock Unchanged
1. After creating sales invoice
2. Check item details
3. ✅ opening_stock should remain unchanged
4. ✅ stock_qty should be reduced

## Migration Results
```
Items with stock_qty > 0: 8 items
Items with opening_stock > 0: 3 items
```

The migration successfully updated existing items.

## Files Modified

### Backend
1. `backend/app/Http/Controllers/ItemController.php`
   - Added logic to set stock_qty from opening_stock

2. `backend/database/migrations/2025_12_06_112424_update_items_stock_qty_from_opening_stock.php`
   - Created migration to fix existing data

## Benefits

1. **Accurate Display:** Items now show correct stock quantities
2. **Automatic Initialization:** No manual intervention needed
3. **Historical Record:** opening_stock preserved for auditing
4. **Backward Compatible:** Existing items automatically fixed
5. **Future Proof:** New items will always have correct stock

## Technical Details

### Database Schema
```sql
-- Items table
opening_stock DECIMAL(10,2) DEFAULT 0  -- Historical initial stock
stock_qty INTEGER DEFAULT 0             -- Current available stock
```

### Logic Flow
```
IF stock_qty NOT provided AND opening_stock provided THEN
    stock_qty = CAST(opening_stock AS INTEGER)
END IF
```

## Edge Cases Handled

1. **No opening_stock provided:** stock_qty remains 0 (valid for service items)
2. **Both provided:** Uses provided stock_qty value
3. **Decimal opening_stock:** Converts to integer for stock_qty
4. **Negative values:** Validation prevents negative stock

## Future Considerations

### Stock Adjustments
When implementing stock adjustment features:
- Update `stock_qty` for current stock changes
- Keep `opening_stock` unchanged
- Log adjustments in stock_movements table (if implemented)

### Stock Reconciliation
For periodic stock counts:
- Compare physical count with `stock_qty`
- Adjust `stock_qty` to match physical count
- Keep `opening_stock` as historical reference

### Reporting
For stock reports:
- Use `stock_qty` for current stock levels
- Use `opening_stock` for initial stock reference
- Calculate total movement: `opening_stock - stock_qty + purchases - sales`

## Status
✅ **COMPLETE** - Stock quantities now display correctly!

## Quick Verification

Run this command to verify the fix:
```bash
cd backend
php artisan tinker --execute="
  \$items = \App\Models\Item::all();
  foreach (\$items as \$item) {
    echo \$item->item_name . ': stock_qty=' . \$item->stock_qty . ', opening_stock=' . \$item->opening_stock . PHP_EOL;
  }
"
```

All items should now have stock_qty matching their opening_stock (unless sales have been made).
