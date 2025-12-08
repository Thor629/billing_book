# Quick Test Guide

## 🎯 Quotation Feature Testing (5 minutes)

### Test 1: Create Basic Quotation
1. Navigate to Sales → Quotations
2. Click "Create Quotation"
3. Click "Add Party" → Search and select a party
4. Click "Add Item" → Search and select an item
5. Verify quantity defaults to 1
6. Verify price defaults to item's selling price
7. Click "Save"
8. ✅ Should see success message
9. ✅ Should navigate back to quotations list

### Test 2: Multiple Items & Calculations
1. Create new quotation
2. Add party
3. Add 3 different items
4. Change quantity of first item to 5
5. Change price of second item
6. Add 10% discount to third item
7. Click "Add Discount" → Enter 100
8. Click "Add Additional Charges" → Enter 50
9. ✅ Verify subtotal updates
10. ✅ Verify tax calculations
11. ✅ Verify total amount is correct
12. Save quotation

### Test 3: Search Functionality
1. Create new quotation
2. Click "Add Party"
3. Type in search box
4. ✅ Should filter parties in real-time
5. Click "Add Item"
6. Type item name/code
7. ✅ Should filter items in real-time
8. ✅ Should show stock quantity
9. Select item and save

### Test 4: Save & New
1. Create quotation with party and items
2. Click "Save & New"
3. ✅ Should save quotation
4. ✅ Should reset form
5. ✅ Should increment quotation number
6. ✅ Should stay on create screen

---

## 📦 Stock Management Testing (5 minutes)

### Test 1: Stock Reduction
**Setup:** Find an item with stock (e.g., 100 units)

1. Note the current stock quantity
2. Create sales invoice with 10 units of that item
3. Save invoice
4. Go to Items screen
5. Find the same item
6. ✅ Stock should be reduced by 10 (now 90)

### Test 2: Insufficient Stock Error
**Setup:** Use item from Test 1 (now has 90 units)

1. Create new sales invoice
2. Add the same item
3. Set quantity to 100 (more than available)
4. Click Save
5. ✅ Should see error: "Insufficient stock for item: [name]. Available: 90, Required: 100"
6. ✅ Invoice should NOT be created
7. ✅ Stock should remain 90

### Test 3: Stock Restoration
**Setup:** Use invoice from Test 1

1. Go to Sales Invoices list
2. Find the invoice created in Test 1
3. Delete the invoice
4. Go to Items screen
5. Find the item
6. ✅ Stock should be restored to 100

### Test 4: Multiple Items
**Setup:** Create invoice with 3 different items

1. Note stock of 3 items (e.g., A=50, B=30, C=20)
2. Create invoice:
   - Item A: 5 units
   - Item B: 3 units
   - Item C: 2 units
3. Save invoice
4. Check all 3 items
5. ✅ Item A should be 45
6. ✅ Item B should be 27
7. ✅ Item C should be 18

---

## 🔍 Edge Cases Testing (Optional)

### Quotation Edge Cases
- [ ] Try to save without party → Should show error
- [ ] Try to save without items → Should show error
- [ ] Add item, then delete it → Should work
- [ ] Change validity days → Should update validity date
- [ ] Remove bank details → Should hide bank section
- [ ] Search with no results → Should show "No items match"

### Stock Edge Cases
- [ ] Create invoice with 0 quantity → Should fail validation
- [ ] Create invoice with decimal quantity (1.5) → Should work
- [ ] Delete invoice twice → Second delete should fail
- [ ] Create invoice with deleted item → Should fail
- [ ] Create invoice, delete it, create again → Stock should be correct

---

## 📊 Visual Verification Checklist

### Quotation Screen
- [ ] Party details display correctly after selection
- [ ] Items table shows all columns
- [ ] Quantity/price fields are editable
- [ ] Delete button removes items
- [ ] Subtotal row shows correct totals
- [ ] Discount button shows amount when set
- [ ] Charges button shows amount when set
- [ ] Total card shows all calculations
- [ ] Bank details display when selected
- [ ] Loading spinner shows during save
- [ ] Success message appears after save

### Stock Management
- [ ] Items screen shows updated stock
- [ ] Error message is clear and helpful
- [ ] Stock doesn't go negative
- [ ] Multiple invoices reduce stock cumulatively
- [ ] Deleted invoices restore stock correctly

---

## 🐛 Common Issues & Solutions

### Issue: Quotation number doesn't increment
**Solution:** Check backend API `/quotations/next-number` is working

### Issue: Stock not reducing
**Solution:** Check backend logs, verify Item model has stock_qty field

### Issue: Search not working
**Solution:** Verify parties/items exist in database for selected organization

### Issue: Calculations wrong
**Solution:** Check discount/tax percentages, verify formula in QuotationItem class

### Issue: Can't save quotation
**Solution:** Check validation errors, ensure party and items are selected

---

## ✅ Quick Success Criteria

### Quotation Feature
- ✅ Can create quotation with party and items
- ✅ Search filters work in real-time
- ✅ Calculations are accurate
- ✅ Save & New resets form
- ✅ Quotation number auto-increments

### Stock Management
- ✅ Stock reduces when invoice is saved
- ✅ Error shown when stock insufficient
- ✅ Stock restores when invoice deleted
- ✅ Multiple items handled correctly
- ✅ Stock never goes negative

---

## 📝 Test Results Template

```
Date: ___________
Tester: ___________

QUOTATION TESTS:
[ ] Test 1: Create Basic Quotation - PASS/FAIL
[ ] Test 2: Multiple Items & Calculations - PASS/FAIL
[ ] Test 3: Search Functionality - PASS/FAIL
[ ] Test 4: Save & New - PASS/FAIL

STOCK TESTS:
[ ] Test 1: Stock Reduction - PASS/FAIL
[ ] Test 2: Insufficient Stock Error - PASS/FAIL
[ ] Test 3: Stock Restoration - PASS/FAIL
[ ] Test 4: Multiple Items - PASS/FAIL

ISSUES FOUND:
1. ___________
2. ___________
3. ___________

OVERALL STATUS: PASS/FAIL
```

---

## 🚀 Ready to Test!

Both features are ready for testing. Start with the basic tests and move to edge cases if time permits.

**Estimated Testing Time:** 15-20 minutes for all basic tests
