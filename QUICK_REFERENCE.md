# Quick Reference Card

## ✅ What's Working Now

### Sales Invoice → Cash & Bank Integration
- Create invoice with payment → Transaction appears in Cash & Bank ✅
- Auto-incrementing invoice numbers ✅
- Searchable party selection ✅
- Searchable item selection ✅
- Real bank account fetching ✅

## 🔄 What's Next

### Quotation Screen Enhancement
Follow the guide in `QUOTATION_ENHANCEMENT_GUIDE.md`

## 🚀 Quick Commands

### Run Flutter App:
```bash
cd flutter_app
flutter run
```

### Run Tests:
```bash
cd flutter_app
flutter test
```

### Run Backend:
```bash
cd backend
php artisan serve
```

## 📂 Key Files

### Sales Invoice:
- `flutter_app/lib/screens/user/create_sales_invoice_screen.dart`
- `flutter_app/lib/screens/user/cash_bank_screen.dart`

### Quotation (To Update):
- `flutter_app/lib/screens/user/create_quotation_screen.dart`

### Services:
- `flutter_app/lib/services/bank_account_service.dart`
- `flutter_app/lib/services/sales_invoice_service.dart`

### Backend:
- `backend/app/Http/Controllers/SalesInvoiceController.php`
- `backend/app/Http/Controllers/BankTransactionController.php`

## 🐛 Debugging

### Check Transactions:
```bash
cd backend
php artisan tinker --execute="print_r(\App\Models\BankTransaction::all()->toArray());"
```

### Check Console Logs:
Look for `DEBUG:` messages in Flutter console

## 📝 Implementation Checklist for Quotation

- [ ] Add imports (Step 1)
- [ ] Add state variables (Step 2)
- [ ] Create QuotationItem class (Step 3)
- [ ] Add initState (Step 4)
- [ ] Add party selection (Step 5)
- [ ] Add item selection (Step 6)
- [ ] Add discount dialog (Step 7)
- [ ] Add charges dialog (Step 8)
- [ ] Copy search dialogs (Step 9)
- [ ] Update calculations (Step 10)
- [ ] Update UI elements (Step 11)
- [ ] Test everything

## 💡 Tips

1. **Copy from Sales Invoice** - Most code can be reused
2. **Test Incrementally** - Test each feature as you add it
3. **Check Imports** - Make sure all imports are added
4. **Use Debug Logs** - Add print statements to troubleshoot
5. **Check Provider** - Ensure Provider is set up correctly

## 🎯 Success Criteria

### Sales Invoice (DONE ✅):
- ✅ Transactions appear in Cash & Bank
- ✅ Invoice numbers auto-increment
- ✅ Search works for parties and items
- ✅ Bank accounts load from Cash & Bank

### Quotation (TODO 🔄):
- [ ] Party selection with search
- [ ] Item selection with search
- [ ] Bank accounts from Cash & Bank
- [ ] Discount dialog functional
- [ ] Additional charges functional

## 📞 Need Help?

1. Read `QUOTATION_ENHANCEMENT_GUIDE.md`
2. Check `SESSION_SUMMARY.md` for context
3. Review spec files in `.kiro/specs/`
4. Check test files for examples
