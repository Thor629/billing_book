# POS Billing - Quick Reference Card

## 🚀 Quick Start (30 Seconds)

1. **Start Backend**: `cd backend && php artisan serve`
2. **Start Flutter**: `cd flutter_app && flutter run`
3. **Open POS**: Click "POS Billing" in menu
4. **Search**: Type 2+ characters
5. **Add Item**: Click item in dropdown
6. **Save**: Enter payment amount, click "Save Bill"

## 🔍 Search Tips

- **Minimum**: 2 characters required
- **Search by**: Item name, item code, or barcode
- **Stock Colors**: 
  - 🟢 Green = Available
  - 🔴 Red = Low stock
- **Auto-clear**: Search clears after adding item

## 📝 Bill Management

### Add Items
- Click item in search results
- Duplicate items → quantity increases

### Adjust Quantity
- **+** button: Increase quantity
- **-** button: Decrease quantity (min: 1)

### Change Price
- Click on price (blue underlined)
- Enter new price
- Click "Update"

### Delete Item
- Click 🗑️ icon on right side of row

## 💰 Payment

### Calculations (Automatic)
- **Sub Total**: Sum of all items
- **Tax**: GST calculated per item
- **Discount**: Enter amount to subtract
- **Additional Charge**: Enter amount to add
- **Total**: Sub Total + Tax - Discount + Charge
- **Change**: Received Amount - Total

### Payment Methods
- Cash
- Card
- UPI
- Cheque

### Cash Sale
- ✅ Check for cash sale (no customer)
- ⬜ Uncheck for credit sale (with customer)

## 💾 Save Options

### Save Bill [F7]
- Saves to database
- Updates stock
- Creates invoice
- Resets bill

### Save & Print [F6]
- Same as Save Bill
- Plus: Sends to printer (future)

## 📊 What Happens on Save

1. ✅ Sales invoice created
2. ✅ Invoice number generated (POS-XXXXXX)
3. ✅ Stock quantities updated
4. ✅ Payment record created
5. ✅ Bill resets to empty
6. ✅ Success message shown

## 🔧 Troubleshooting

### No Search Results?
- ✓ Check organization selected
- ✓ Type at least 2 characters
- ✓ Verify items exist in database
- ✓ Check items are active

### Can't Save Bill?
- ✓ Add at least one item
- ✓ Enter received amount
- ✓ Check backend is running
- ✓ Verify organization selected

### Stock Not Updating?
- ✓ Check backend logs
- ✓ Verify database connection
- ✓ Check item IDs are correct

## 📁 Important Files

### Backend
- `backend/app/Http/Controllers/PosController.php`
- `backend/routes/api.php`

### Frontend
- `flutter_app/lib/screens/user/pos_billing_screen.dart`
- `flutter_app/lib/services/pos_service.dart`

### Documentation
- `TEST_POS_SEARCH.md` - Quick test guide
- `POS_SEARCH_FUNCTIONALITY_COMPLETE.md` - Full details
- `SESSION_SUMMARY_POS_COMPLETE.md` - Implementation summary

## 🎯 Keyboard Shortcuts (Future)

- **F6**: Save & Print
- **F7**: Save Bill
- **F8**: Hold Bill
- **ESC**: Clear Bill
- **F1**: Help

## 📞 API Endpoints

```
GET  /api/pos/search-items        - Search items
GET  /api/pos/item-by-barcode     - Get by barcode
POST /api/pos/save-bill           - Save bill
```

## ✅ Status Check

Run this to verify everything:

```bash
# Check backend
cd backend
php artisan route:list | grep pos

# Check items in database
php artisan tinker --execute="echo DB::table('items')->count();"

# Check diagnostics
# (All should show 0 errors, 0 warnings)
```

## 🎉 Success Indicators

- ✅ Search shows results
- ✅ Items add to bill
- ✅ Quantities adjust
- ✅ Prices change
- ✅ Bill saves
- ✅ Stock updates
- ✅ Invoice generated

## 📈 Next Features

1. Barcode scanner integration
2. Hold bill functionality
3. Customer selection
4. Print receipts
5. Daily sales report
6. Keyboard shortcuts

---

**Status**: ✅ FULLY FUNCTIONAL
**Version**: 1.0
**Last Updated**: Migration completed, all bugs fixed
