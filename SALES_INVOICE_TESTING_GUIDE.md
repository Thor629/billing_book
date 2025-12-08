# Sales Invoice Testing Guide

## Prerequisites

Before testing, ensure you have:
1. ✅ Backend server running (`php artisan serve`)
2. ✅ Flutter app running (`flutter run`)
3. ✅ At least one organization created
4. ✅ At least one party created
5. ✅ At least one item created
6. ✅ At least one bank account created (optional)
7. ✅ User logged in with access to the organization

## Test Scenarios

### Scenario 1: Create Invoice with Single Item

**Steps:**
1. Navigate to Sales → Create Sales Invoice
2. Click "+ Add Party"
3. Select a party from the list
4. Verify party details are displayed
5. Click "+ Add Item"
6. Select an item from the list
7. Verify item is added to the table
8. Check that calculations are correct:
   - Subtotal = Quantity × Price
   - Discount = Subtotal × (Discount % / 100)
   - Tax = (Subtotal - Discount) × (Tax % / 100)
   - Line Total = Subtotal - Discount + Tax
9. Verify bank account is auto-loaded (if exists)
10. Enter payment amount (optional)
11. Click "Save"
12. Verify invoice is created successfully

**Expected Results:**
- ✅ Party is selected and displayed
- ✅ Item is added to invoice
- ✅ All calculations are correct
- ✅ Bank account is displayed
- ✅ Invoice is saved successfully

### Scenario 2: Create Invoice with Multiple Items

**Steps:**
1. Navigate to Sales → Create Sales Invoice
2. Add a party
3. Click "+ Add Item" multiple times
4. Add 3-5 different items
5. Modify quantities for each item
6. Modify prices for some items
7. Add discounts to some items
8. Verify totals update correctly
9. Save the invoice

**Expected Results:**
- ✅ All items are added correctly
- ✅ Subtotal = Sum of all line subtotals
- ✅ Total Discount = Sum of all line discounts
- ✅ Total Tax = Sum of all line taxes
- ✅ Total Amount = Subtotal - Total Discount + Total Tax

### Scenario 3: Edit Item Quantities and Prices

**Steps:**
1. Start creating an invoice
2. Add an item
3. Change the quantity field
4. Verify line total updates
5. Change the price per unit
6. Verify line total updates
7. Change the discount percentage
8. Verify line total updates
9. Verify all totals in the right panel update

**Expected Results:**
- ✅ Line total updates immediately
- ✅ Subtotal updates
- ✅ Total discount updates
- ✅ Total tax updates
- ✅ Total amount updates

### Scenario 4: Delete Items

**Steps:**
1. Start creating an invoice
2. Add 3 items
3. Click delete icon on the second item
4. Verify item is removed
5. Verify totals are recalculated
6. Delete another item
7. Verify totals update again

**Expected Results:**
- ✅ Items are deleted correctly
- ✅ Totals recalculate after each deletion
- ✅ Remaining items stay intact

### Scenario 5: Change Party

**Steps:**
1. Start creating an invoice
2. Select a party
3. Click "Change Party"
4. Select a different party
5. Verify new party details are displayed
6. Add items and complete invoice

**Expected Results:**
- ✅ Party is changed successfully
- ✅ New party details are displayed
- ✅ Invoice can be completed with new party

### Scenario 6: Bank Account Selection (Single Account)

**Steps:**
1. Ensure user has only one bank account
2. Start creating an invoice
3. Verify bank account is auto-loaded
4. Verify bank details are displayed:
   - Account Number
   - IFSC Code
   - Bank Name
   - Account Holder Name
   - UPI ID
5. Click "Remove Bank Account"
6. Verify bank details are hidden

**Expected Results:**
- ✅ Bank account auto-loads
- ✅ All bank details are displayed correctly
- ✅ Remove button works

### Scenario 7: Bank Account Selection (Multiple Accounts)

**Steps:**
1. Ensure user has multiple bank accounts
2. Start creating an invoice
3. Verify first bank account is auto-loaded
4. Click "Change Bank Account"
5. Verify dialog shows all bank accounts
6. Select a different account
7. Verify new account details are displayed
8. Complete the invoice

**Expected Results:**
- ✅ First account auto-loads
- ✅ Change button appears
- ✅ All accounts are listed in dialog
- ✅ Selected account details are displayed

### Scenario 8: Payment Tracking

**Steps:**
1. Create an invoice with total amount ₹1000
2. Leave payment amount as ₹0
3. Verify balance amount shows ₹1000 (red)
4. Enter payment amount ₹500
5. Verify balance amount shows ₹500 (red)
6. Enter payment amount ₹1000
7. Verify balance amount shows ₹0 (green)
8. Check "Mark as fully paid"
9. Verify payment amount auto-fills to total

**Expected Results:**
- ✅ Balance = Total - Payment
- ✅ Balance is red when unpaid
- ✅ Balance is green when paid
- ✅ "Mark as fully paid" auto-fills amount

### Scenario 9: Payment Modes

**Steps:**
1. Start creating an invoice
2. Check available payment modes:
   - Cash
   - Card
   - UPI
   - Bank Transfer
3. Select each mode
4. Verify selection is saved

**Expected Results:**
- ✅ All payment modes are available
- ✅ Selection works correctly

### Scenario 10: Invoice Number Auto-Increment

**Steps:**
1. Create invoice with number 101
2. Save successfully
3. Create another invoice
4. Verify number auto-increments to 102
5. Create another invoice
6. Verify number is 103

**Expected Results:**
- ✅ Invoice numbers auto-increment
- ✅ No duplicate numbers

### Scenario 11: Date Selection

**Steps:**
1. Start creating an invoice
2. Click on Invoice Date
3. Select a date from date picker
4. Verify date is displayed
5. Change payment terms to 45 days
6. Verify due date updates automatically
7. Click on Due Date
8. Select a custom due date
9. Verify custom date is saved

**Expected Results:**
- ✅ Date picker works
- ✅ Due date auto-calculates
- ✅ Custom due date can be set

### Scenario 12: No Parties Available

**Steps:**
1. Ensure organization has no parties
2. Start creating an invoice
3. Click "+ Add Party"
4. Verify "No parties found" message

**Expected Results:**
- ✅ Shows "No parties found" message
- ✅ No errors occur

### Scenario 13: No Items Available

**Steps:**
1. Ensure organization has no items
2. Start creating an invoice
3. Click "+ Add Item"
4. Verify "No items found" message

**Expected Results:**
- ✅ Shows "No items found" message
- ✅ No errors occur

### Scenario 14: No Bank Accounts

**Steps:**
1. Ensure user has no bank accounts
2. Start creating an invoice
3. Verify no bank details section appears
4. Complete invoice without bank details

**Expected Results:**
- ✅ No bank section shown
- ✅ Invoice can be created without bank details

### Scenario 15: Loading States

**Steps:**
1. Start creating an invoice
2. Observe loading indicator while bank accounts load
3. Click "+ Add Party"
4. Observe loading while parties load
5. Click "+ Add Item"
6. Observe loading while items load

**Expected Results:**
- ✅ Loading indicators appear
- ✅ No errors during loading
- ✅ Data loads successfully

## API Testing

### Test API Endpoints Directly

#### 1. Get Invoices
```bash
curl -X GET "http://localhost:8000/api/sales-invoices?organization_id=1" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Expected:** List of invoices with summary

#### 2. Create Invoice
```bash
curl -X POST http://localhost:8000/api/sales-invoices \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "organization_id": 1,
    "party_id": 1,
    "invoice_prefix": "TEST",
    "invoice_number": "001",
    "invoice_date": "2025-01-04",
    "payment_terms": 30,
    "due_date": "2025-02-03",
    "items": [{
      "item_id": 1,
      "item_name": "Test Item",
      "quantity": 1,
      "price_per_unit": 100,
      "discount_percent": 0,
      "tax_percent": 18
    }]
  }'
```

**Expected:** Invoice created with ID

#### 3. Get Next Invoice Number
```bash
curl -X GET "http://localhost:8000/api/sales-invoices/next-number?organization_id=1&prefix=TEST" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Expected:** Next available number

## Error Testing

### Test Error Scenarios

#### 1. Missing Organization ID
**Test:** Call API without organization_id
**Expected:** 400 Bad Request

#### 2. Invalid Party ID
**Test:** Create invoice with non-existent party_id
**Expected:** 422 Validation Error

#### 3. Invalid Item ID
**Test:** Create invoice with non-existent item_id
**Expected:** 422 Validation Error

#### 4. Duplicate Invoice Number
**Test:** Create two invoices with same number
**Expected:** 422 Error "Invoice number already exists"

#### 5. No Access to Organization
**Test:** Try to access another user's organization
**Expected:** 403 Forbidden

## Performance Testing

### Test Performance

1. **Load Time**
   - Measure time to load create invoice screen
   - Should be < 2 seconds

2. **Party Selection**
   - Test with 100+ parties
   - Dialog should load quickly

3. **Item Selection**
   - Test with 100+ items
   - Dialog should load quickly

4. **Calculation Speed**
   - Add 20 items
   - Change quantities
   - Calculations should be instant

## Browser/Device Testing

### Test on Different Platforms

- [ ] Windows Desktop
- [ ] Mac Desktop
- [ ] Linux Desktop
- [ ] Android Phone
- [ ] Android Tablet
- [ ] iOS Phone
- [ ] iOS Tablet
- [ ] Web Browser (Chrome)
- [ ] Web Browser (Firefox)
- [ ] Web Browser (Safari)

## Regression Testing

### Verify Existing Features Still Work

- [ ] Login/Logout
- [ ] Organization selection
- [ ] Party management
- [ ] Item management
- [ ] Bank account management
- [ ] Other sales features
- [ ] Dashboard

## Bug Reporting Template

When you find a bug, report it with:

```
**Bug Title:** [Short description]

**Steps to Reproduce:**
1. Step 1
2. Step 2
3. Step 3

**Expected Result:**
What should happen

**Actual Result:**
What actually happened

**Screenshots:**
[Attach screenshots]

**Environment:**
- OS: [Windows/Mac/Linux/Android/iOS]
- Browser/Device: [Chrome/Firefox/Safari/Phone Model]
- App Version: [Version number]

**Additional Notes:**
Any other relevant information
```

## Test Completion Checklist

- [ ] All 15 scenarios tested
- [ ] API endpoints tested
- [ ] Error scenarios tested
- [ ] Performance acceptable
- [ ] Multiple platforms tested
- [ ] No critical bugs found
- [ ] Documentation reviewed
- [ ] Ready for production

## Notes

- Test with real data when possible
- Test edge cases (very large numbers, special characters, etc.)
- Test with slow internet connection
- Test with multiple users simultaneously
- Keep track of any issues found
- Retest after fixes are applied

## Support

If you encounter issues:
1. Check the error message
2. Review the documentation
3. Check the backend logs
4. Check the Flutter console
5. Report the bug using the template above
