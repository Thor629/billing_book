# Sales Invoice Save Functionality - Complete

## Problem
The "Save" button in the Create Sales Invoice screen was not functional. When users clicked the button, nothing happened because the `onPressed` handler was empty.

## Solution Implemented

### 1. Added Sales Invoice Service Import
**File: `flutter_app/lib/screens/user/create_sales_invoice_screen.dart`**

Added the import for `SalesInvoiceService` to enable API calls for creating invoices.

### 2. Implemented Save Invoice Method
Created a comprehensive `_saveInvoice()` method that:

**Validation:**
- Checks if a party is selected
- Checks if at least one item is added
- Checks if an organization is selected

**Data Preparation:**
- Collects all invoice data including:
  - Organization and party information
  - Invoice prefix, number, dates
  - Payment terms and amounts
  - All line items with quantities, prices, discounts, and taxes
  - Bank account details (if selected)
  - Payment status (automatically set based on amount received)

**API Call:**
- Calls `SalesInvoiceService.createInvoice()` with the prepared data
- Shows loading indicator during the save process
- Handles success and error cases with appropriate messages

**User Feedback:**
- Shows success message in green snackbar
- Shows error message in red snackbar
- Closes the dialog and returns to the invoice list on success

### 3. Updated Save Button
- Connected the Save button to the `_saveInvoice()` method
- Added loading state to disable button and show spinner during save
- Button is disabled while saving to prevent duplicate submissions

### 4. Implemented Save & New Functionality
Created a `_saveAndNew()` method that:
- Saves the current invoice
- Resets the form to create a new invoice
- Clears selected party and items
- Resets dates and payment amounts
- Allows quick creation of multiple invoices

### 5. Updated Sales Invoices Screen
The dialog already had proper handling to reload invoices after closing:
```dart
await _showCreateInvoiceDialog();
_loadInvoices(); // Reloads the invoice list
```

## How It Works Now

1. **User fills out the invoice form:**
   - Selects a party
   - Adds items with quantities and prices
   - Sets payment details

2. **User clicks "Save":**
   - Form is validated
   - Loading indicator appears
   - Invoice data is sent to the backend
   - Success/error message is shown

3. **On Success:**
   - Dialog closes automatically
   - Invoice list is refreshed
   - New invoice appears in the table

4. **Save & New Option:**
   - Saves the invoice
   - Keeps the dialog open
   - Resets the form for the next invoice

## Data Structure Sent to Backend

```json
{
  "organization_id": 1,
  "party_id": 5,
  "invoice_prefix": "SHI",
  "invoice_number": "101",
  "invoice_date": "2024-12-04",
  "due_date": "2025-01-03",
  "payment_terms": 30,
  "subtotal": 1000.00,
  "discount_amount": 50.00,
  "tax_amount": 171.00,
  "total_amount": 1121.00,
  "amount_received": 500.00,
  "balance_amount": 621.00,
  "payment_status": "unpaid",
  "payment_mode": "Cash",
  "bank_account_id": 2,
  "items": [
    {
      "item_id": 10,
      "quantity": 2,
      "price_per_unit": 500.00,
      "discount_percent": 5,
      "tax_percent": 18,
      "subtotal": 1000.00,
      "discount_amount": 50.00,
      "tax_amount": 171.00,
      "line_total": 1121.00
    }
  ]
}
```

## Testing

To test the fix:
1. Navigate to Sales Invoices screen
2. Click "Create Sales Invoice"
3. Select a party
4. Add one or more items
5. Enter payment details (optional)
6. Click "Save"
7. Verify the invoice appears in the list
8. Check that the totals are calculated correctly

## Files Modified
- `flutter_app/lib/screens/user/create_sales_invoice_screen.dart`

## Features Added
- ✅ Full invoice validation before save
- ✅ Loading indicator during save
- ✅ Success/error feedback messages
- ✅ Automatic dialog close on success
- ✅ Invoice list refresh after creation
- ✅ Save & New functionality for bulk entry
- ✅ Automatic payment status calculation
- ✅ Support for partial payments
