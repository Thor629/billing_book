# Expense Feature - Testing Guide

## Setup Complete ✅

The database has been migrated and the Expense feature is fully integrated into the app.

## How to Test

### 1. Access Expenses Screen
1. Login to the app
2. In the left sidebar, scroll to "ACCOUNTING SOLUTIONS" section
3. Click on "Expenses" menu item
4. You should see the Expenses list screen

### 2. Create Your First Expense

#### Test Case 1: Cash Expense
1. Click "Create Expense" button
2. Fill in the form:
   - **Expense Category**: Select "Office Supplies"
   - **Expense Number**: Auto-filled (e.g., "1")
   - **Date**: Select today's date
   - **Payment Mode**: Select "Cash"
   - Click "+ Add Item" button
3. In the Add Item dialog:
   - **Item Name**: "Printer Paper"
   - **Description**: "A4 size, 500 sheets"
   - **Quantity**: 5
   - **Rate**: 100
   - **Amount**: Will auto-calculate to 500
   - Click "Add"
4. Add **Notes** (optional): "Monthly office supplies"
5. Click "Save"
6. **Expected Result**: 
   - Success message appears
   - Expense appears in the list
   - Go to "Cash & Bank" screen
   - "Cash in Hand" balance should be decreased by ₹500

#### Test Case 2: Bank Expense
1. Click "Create Expense" button
2. Fill in the form:
   - **Expense Category**: Select "Rent Expense"
   - **Expense Number**: Auto-filled (e.g., "2")
   - **Date**: Select today's date
   - **Payment Mode**: Select "Bank Transfer"
   - **Bank Account**: Select a bank account from the list
   - Click "+ Add Item"
3. In the Add Item dialog:
   - **Item Name**: "Office Rent"
   - **Description**: "December 2025"
   - **Quantity**: 1
   - **Rate**: 25000
   - **Amount**: 25000
   - Click "Add"
4. Click "Save"
5. **Expected Result**:
   - Success message appears
   - Expense appears in the list
   - Go to "Cash & Bank" screen
   - Selected bank account balance should be decreased by ₹25,000

### 3. Test Filters

#### Date Filter
1. On Expenses screen, click the date dropdown
2. Select "Last 7 Days"
3. **Expected**: Only expenses from last 7 days show

#### Category Filter
1. Click the category dropdown
2. Select a specific category
3. **Expected**: Only expenses from that category show

#### Search
1. Type an expense number in the search box
2. **Expected**: Matching expenses appear

### 4. Test Multi-Item Expense
1. Create a new expense
2. Add multiple items:
   - Item 1: "Laptop", Qty: 2, Rate: 50000
   - Item 2: "Mouse", Qty: 5, Rate: 500
   - Item 3: "Keyboard", Qty: 3, Rate: 1500
3. **Expected Total**: ₹105,500
4. Save and verify the total is correct

### 5. Test Validation

#### Missing Category
1. Try to save without selecting a category
2. **Expected**: Error message "Please select a category"

#### No Items
1. Try to save without adding any items
2. **Expected**: Error message "Please add at least one item"

#### Bank Account Required
1. Select payment mode "Card" or "UPI"
2. Don't select a bank account
3. Try to save
4. **Expected**: Error message "Please select a bank account"

### 6. Verify Balance Updates

#### Before Creating Expense
1. Go to "Cash & Bank" screen
2. Note down current balances:
   - Cash in Hand: ₹_____
   - Bank Account 1: ₹_____

#### After Creating Cash Expense (₹1,000)
1. Create a cash expense for ₹1,000
2. Go back to "Cash & Bank" screen
3. **Expected**: Cash in Hand decreased by ₹1,000

#### After Creating Bank Expense (₹5,000)
1. Create a bank expense for ₹5,000
2. Select a specific bank account
3. Go back to "Cash & Bank" screen
4. **Expected**: Selected bank account decreased by ₹5,000

## Common Issues & Solutions

### Issue: "Expense number already exists"
**Solution**: The expense number auto-increments. If you see this error, refresh the page or manually change the number.

### Issue: No bank accounts in dropdown
**Solution**: First create bank accounts in the "Cash & Bank" screen before creating bank expenses.

### Issue: No categories in dropdown
**Solution**: Categories are loaded from the backend. Check your internet connection and backend status.

## Expected Behavior Summary

✅ Expenses list displays all expenses
✅ Filters work correctly (date, category, search)
✅ Create expense form validates all fields
✅ Multi-item support works
✅ Cash expenses deduct from "Cash in Hand"
✅ Bank expenses deduct from selected bank account
✅ Total amount calculates correctly
✅ Success messages appear after saving
✅ Expenses appear immediately in the list

## Database Verification

To verify expenses are saved correctly:

```bash
cd backend
sqlite3 database/database.sqlite

# View all expenses
SELECT * FROM expenses;

# View expense items
SELECT * FROM expense_items;

# View with party names
SELECT e.expense_number, e.category, e.total_amount, p.name as party_name
FROM expenses e
LEFT JOIN parties p ON e.party_id = p.id;
```

## API Testing

Test the API endpoints directly:

```bash
# Get expenses
GET /api/expenses?organization_id=1

# Create expense
POST /api/expenses
{
  "organization_id": 1,
  "expense_number": "1",
  "expense_date": "2025-12-08",
  "category": "Office Supplies",
  "payment_mode": "Cash",
  "total_amount": 500,
  "with_gst": false,
  "items": [
    {
      "item_name": "Test Item",
      "quantity": 1,
      "rate": 500,
      "amount": 500
    }
  ]
}

# Get categories
GET /api/expenses/categories

# Get next expense number
GET /api/expenses/next-number?organization_id=1
```

## Success Criteria

The feature is working correctly if:
- ✅ You can create expenses with multiple items
- ✅ Cash/Bank balances update automatically
- ✅ Filters and search work
- ✅ Validation prevents invalid data
- ✅ UI matches the provided screenshots
- ✅ Data persists in the database
