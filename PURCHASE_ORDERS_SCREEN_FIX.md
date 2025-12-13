# Purchase Orders Screen Fix

## Problem
The Purchase Orders menu was showing "Coming Soon" placeholder instead of the actual screen.

## Root Cause
The `user_dashboard.dart` was routing to `_buildPlaceholderScreen('Purchase Orders')` instead of the actual `PurchaseOrdersScreen` we created.

## Solution Applied

### Changes Made
1. **Added import** in `flutter_app/lib/screens/user/user_dashboard.dart`:
   ```dart
   import 'purchase_orders_screen.dart';
   ```

2. **Fixed routing** (case 18):
   ```dart
   // Before:
   case 18:
     return _buildPlaceholderScreen('Purchase Orders');
   
   // After:
   case 18:
     return const PurchaseOrdersScreen();
   ```

## How to Test

### Step 1: Hot Restart Flutter App
Press `R` in the terminal where Flutter is running, or:
```bash
# Stop the app (Ctrl+C) and restart
cd flutter_app
flutter run
```

### Step 2: Navigate to Purchase Orders
1. Login to the app
2. Click on **Purchases** menu (left sidebar)
3. Click on **Purchase Orders**
4. **Expected**: Should now show the actual Purchase Orders screen with:
   - List of purchase orders (if any)
   - "Create Purchase Order" button
   - Filters and search

### Step 3: Test Create Purchase Order
1. Click **"+ Create Purchase Order"** button
2. Should open the create form with all features:
   - Add party
   - Add items
   - Fully paid checkbox
   - Additional discount
   - Additional charges
   - Auto round-off
   - Bank account selection

## What You Should See Now

### ✅ Purchase Orders List Screen
- Header: "Purchase Orders"
- Button: "+ Create Purchase Order"
- Filters: Date range, party, status
- Table with columns: PO Number, Date, Party, Amount, Status, Actions
- Empty state if no orders yet

### ✅ Create Purchase Order Screen
- Form with all fields
- Party selection
- Items table
- Calculations (subtotal, tax, discount, charges, total)
- Bank account dropdown
- Save button

## Status
✅ **FIXED** - Purchase Orders screen is now properly integrated

## Next Steps
1. Hot restart the Flutter app
2. Navigate to Purchases → Purchase Orders
3. Test creating a purchase order
4. Verify all features work correctly

---

**Note**: If you still see "Coming Soon", make sure to:
1. Hot restart (not just hot reload)
2. Check console for any errors
3. Verify the import was added correctly
