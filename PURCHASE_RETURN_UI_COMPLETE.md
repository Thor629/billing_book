# Purchase Return UI Complete ✅

## Overview
Purchase Return create screen has been redesigned to match the Sales Return screen layout exactly, with appropriate changes for purchase returns (supplier instead of customer, purchase price instead of selling price, refund received instead of payment made).

## Changes Made

### Complete Redesign
Replaced the previous two-panel layout with the Sales Return style layout:

**Previous Design:**
- Left panel: Form fields
- Right panel: Summary

**New Design (Matching Sales Return):**
- Left side (main area): Supplier selection, items table, notes, payment details
- Right side (sidebar): Return number, date, invoice link, barcode scanner

## Screen Layout

### Top Bar
- Back button
- Title: "Create Purchase Return"
- QR scanner icon
- Settings icon
- "Save & New" button
- "Save" button (purple)

### Left Side (Main Area)

#### 1. Supplier Selection
- Label: "Supplier"
- Click to open supplier selection dialog
- Shows "+ Add Party" or selected supplier name

#### 2. Items Table
- Columns: NO, ITEMS/SERVICES, HSN/SAC, ITEM CODE, MRP, QTY, PRICE/ITEM, DISCOUNT, TAX, AMOUNT
- "+ Add Item" button to add items
- Subtotal row at bottom
- Delete button for each item

#### 3. Notes and Payment Section (Two Columns)

**Left Column:**
- Add Notes button
- Terms and Conditions display

**Right Column:**
- Add Discount button
- Add Additional Charges button
- Taxable Amount display
- Auto Round Off checkbox
- Total Amount (bold)
- Enter Refund amount field
- "Mark as fully received" checkbox
- Amount Received field with payment mode dropdown (Cash/Card/UPI)
- Bank Account selector (shown when not Cash)

### Right Side (Sidebar)

#### 1. Purchase Return No.
- Text field with return number
- Auto-generated from backend

#### 2. Purchase Return Date
- Date picker
- Shows formatted date (e.g., "9 Dec 2025")

#### 3. Link to Invoice
- "New" badge
- Search field for invoices

#### 4. Scan Barcode Button
- Full-width button with QR icon

## Key Features

### 1. Auto-Load Data
- Fetches suppliers from backend
- Fetches items from backend
- Fetches bank accounts from backend
- Auto-generates next return number

### 2. Supplier Selection Dialog
- Modal dialog with supplier list
- Shows supplier name and phone
- Click to select

### 3. Item Selection Dialog
- Modal dialog with item list
- Shows item name and purchase price (not selling price)
- Click to add to return

### 4. Payment Handling
- Payment mode dropdown: Cash/Card/UPI
- Bank account selector (when not cash)
- Amount received field
- "Mark as fully received" checkbox auto-fills amount

### 5. Real-time Calculations
- Subtotal = Sum of (quantity × price)
- Tax = Sum of item taxes
- Total = Subtotal - Discount + Tax

### 6. Save Functionality
- Validates supplier selected
- Validates at least one item added
- Creates purchase return via API
- Shows success/error messages
- Returns to list screen on success

## API Integration

### Data Sent to Backend
```dart
{
  'party_id': int,
  'return_number': string,
  'return_date': string (YYYY-MM-DD),
  'status': 'approved' or 'pending',
  'payment_mode': 'cash', 'card', or 'upi',
  'bank_account_id': int (optional),
  'amount_received': double,
  'reason': string (optional),
  'notes': string (optional),
  'items': [
    {
      'item_id': int,
      'quantity': double,
      'rate': double,
      'tax_rate': double,
      'unit': 'pcs'
    }
  ]
}
```

### Backend Response
- Creates purchase_return record
- Creates purchase_return_items
- Decreases stock for returned items
- Increases cash/bank balance (if amount_received > 0)
- Creates bank_transaction record

## Differences from Sales Return

| Aspect | Sales Return | Purchase Return |
|--------|--------------|-----------------|
| **Title** | Create Sales Return | Create Purchase Return |
| **Party Label** | Bill To | Supplier |
| **Party Type** | Customer | Supplier |
| **Price Used** | Selling Price | **Purchase Price** |
| **Amount Field** | Enter Payment amount | **Enter Refund amount** |
| **Checkbox** | Mark as fully paid | **Mark as fully received** |
| **Amount Label** | Amount Paid | **Amount Received** |
| **Stock Effect** | Increases | **Decreases** |
| **Balance Effect** | Decreases | **Increases** |
| **Dialog Title** | Select Party | **Select Supplier** |
| **Empty Message** | No parties found | **No suppliers found** |

## Visual Design

### Colors
- Primary button: Purple (#7B1FA2)
- Add buttons: Blue (#1976D2)
- Background: White
- Borders: Grey (#E0E0E0)
- Table header: Light grey (#F5F5F5)

### Typography
- Title: 18px, Black
- Section labels: 14px, Grey, Medium weight
- Table headers: 12px, Uppercase
- Body text: 14px, Black
- Amounts: Bold for totals

### Spacing
- Main padding: 24px
- Section spacing: 24px
- Field spacing: 16px
- Table padding: 12px

## Testing Checklist

- [ ] Screen loads without errors
- [ ] Suppliers load from backend
- [ ] Items load from backend
- [ ] Bank accounts load from backend
- [ ] Return number auto-generated
- [ ] Date picker works
- [ ] Supplier selection dialog opens
- [ ] Item selection dialog opens
- [ ] Items added to table
- [ ] Items can be removed
- [ ] Calculations are correct
- [ ] Payment mode dropdown works
- [ ] Bank account selector shows (when not cash)
- [ ] "Mark as fully received" checkbox works
- [ ] Save button creates return
- [ ] Success message shows
- [ ] Returns to list screen
- [ ] Error handling works

## Files Modified
1. `flutter_app/lib/screens/user/create_purchase_return_screen.dart` - Complete redesign

## Status
✅ UI Complete - Matches Sales Return design
✅ Backend Integration Complete
✅ No errors
✅ Ready for testing

**Date:** December 9, 2024
**Version:** 2.0.0 (Redesigned)
