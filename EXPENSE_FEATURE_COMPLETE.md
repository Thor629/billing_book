# Expense Management Feature - Complete Implementation ✅

## Overview
Complete expense tracking system with automatic bank account balance updates, similar to Payment In feature.

## Backend Implementation

### 1. Database (Migration)
- **expenses table**: Main expense records
  - organization_id, user_id, party_id (optional)
  - expense_number, expense_date, category
  - payment_mode, bank_account_id (optional)
  - total_amount, with_gst, notes
  - original_invoice_number

- **expense_items table**: Line items for each expense
  - expense_id, item_name, description
  - quantity, rate, amount

### 2. Models
- `Expense.php` - Main expense model with relationships
- `ExpenseItem.php` - Expense line items

### 3. Controller (`ExpenseController.php`)
- `index()` - List expenses with filters (date, category, search)
- `store()` - Create expense and update bank balance
- `show()` - Get single expense
- `destroy()` - Delete expense
- `getNextExpenseNumber()` - Auto-increment expense numbers
- `getCategories()` - Get predefined expense categories
- `updateBankAccountBalance()` - Deduct from cash/bank account

### 4. Routes (`/api/expenses`)
- GET `/` - List expenses
- POST `/` - Create expense
- GET `/{id}` - Show expense
- DELETE `/{id}` - Delete expense
- GET `/next-number` - Get next expense number
- GET `/categories` - Get expense categories

### 5. Bank Integration
**Automatic Balance Updates:**
- **Cash Payment**: Decreases "Cash in Hand" balance
- **Bank Payment**: Decreases selected bank account balance

## Frontend Implementation

### 1. Models (`expense_model.dart`)
- `Expense` - Main expense model
- `ExpenseItem` - Line item model
- `Party` - Party reference
- `BankAccount` - Bank account reference

### 2. Service (`expense_service.dart`)
- `getExpenses()` - Fetch expenses with filters
- `createExpense()` - Create new expense
- `deleteExpense()` - Delete expense
- `getNextExpenseNumber()` - Get next number
- `getCategories()` - Get categories list
- `getBankAccounts()` - Get bank accounts

### 3. Screens

#### ExpensesScreen (List View)
- Search functionality
- Date filter (Last 7/30/90/365 Days)
- Category filter
- Data table with columns:
  - Date
  - Expense Number
  - Party Name
  - Category
  - Amount
- "Create Expense" button

#### CreateExpenseScreen (Form)
**Left Side:**
- Expense With GST toggle
- Expense Category dropdown
- Expense Number field
- Add Item button (opens dialog)
- Items list display
- Total Expense Amount

**Right Side:**
- Original Invoice Number
- Date picker
- Payment Mode dropdown
- Bank Account selector (for non-cash)
- Notes textarea

**Add Item Dialog:**
- Item Name
- Description
- Quantity
- Rate
- Auto-calculated Amount

## Features

### 1. Expense Categories
20 predefined categories:
- Advertising & Marketing
- Automobile Expense
- Bank Charges & Fees
- Consultant Expense
- IT & Internet Expenses
- Office Supplies
- Rent Expense
- Salary Expense
- Travel Expense
- Utility Expense
- And 10 more...

### 2. Payment Modes
- Cash
- Card
- UPI
- Bank Transfer
- Cheque

### 3. Automatic Balance Updates
- Cash expenses → Deduct from "Cash in Hand"
- Bank expenses → Deduct from selected bank account
- Real-time balance tracking

### 4. Multi-Item Support
- Add multiple line items per expense
- Each item has: name, description, quantity, rate
- Auto-calculate item amounts
- Display total expense amount

### 5. Validation
- Required fields: Category, Items, Expense Number
- Bank account required for non-cash payments
- Minimum one item required
- Positive amounts only

## Usage Flow

1. **User clicks "Create Expense"**
2. **Fills expense details:**
   - Select category
   - Add items (click "+ Add Item")
   - Choose payment mode
   - Select bank account (if not cash)
   - Add notes (optional)
3. **Clicks "Save"**
4. **System:**
   - Creates expense record
   - Saves all line items
   - Updates bank/cash balance (deducts amount)
   - Shows success message
5. **Expense appears in list**

## Testing Steps

1. **Create Cash Expense:**
   - Category: "Office Supplies"
   - Add item: "Printer Paper", Qty: 5, Rate: 100
   - Payment Mode: Cash
   - Save
   - Check "Cash in Hand" balance decreased by ₹500

2. **Create Bank Expense:**
   - Category: "Rent Expense"
   - Add item: "Office Rent", Qty: 1, Rate: 25000
   - Payment Mode: Bank Transfer
   - Select bank account
   - Save
   - Check selected bank balance decreased by ₹25,000

3. **View Expenses List:**
   - Filter by date range
   - Filter by category
   - Search by expense number or party name

## Database Migration

Run migration:
```bash
cd backend
php artisan migrate
```

## Integration Points

- **Organizations**: Expenses are organization-specific
- **Parties**: Optional party association
- **Bank Accounts**: Automatic balance updates
- **Cash & Bank Screen**: Reflects expense deductions

## Benefits

✅ Complete expense tracking
✅ Automatic financial record keeping
✅ Multi-item expense support
✅ Flexible payment modes
✅ Real-time balance updates
✅ Comprehensive filtering and search
✅ Professional UI matching design
