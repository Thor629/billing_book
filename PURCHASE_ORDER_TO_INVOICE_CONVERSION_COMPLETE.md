# Purchase Order to Invoice Conversion - COMPLETE ✅

## Feature Overview

Implemented complete "Convert to Purchase Invoice" functionality that:
1. Creates a purchase invoice from purchase order
2. Updates stock quantities (increases for purchase)
3. Updates bank account balance (decreases for payment)
4. Creates bank transaction record
5. Marks purchase order as converted

## Flow Diagram

```
Purchase Order Created
        ↓
[Convert to Invoice Button]
        ↓
Confirmation Dialog
        ↓
Backend Processing:
  • Create Purchase Invoice
  • Copy all items
  • Update Stock (+quantity)
  • Update Bank Balance (-payment)
  • Create Bank Transaction
  • Mark PO as Converted
        ↓
Success Message
        ↓
Purchase Order Status: "Converted"
```

## Database Changes

### Migration: `2025_12_13_130000_add_conversion_fields_to_purchase_orders.php`

Added 3 new columns to `purchase_orders` table:
- `converted_to_invoice` (boolean, default: false)
- `purchase_invoice_id` (foreign key to purchase_invoices)
- `converted_at` (timestamp, nullable)

**Run Migration:**
```bash
cd backend
php artisan migrate
```

## Backend Implementation

### 1. PurchaseOrderController - New Method

**Endpoint:** `POST /api/purchase-orders/{id}/convert-to-invoice`

**Method:** `convertToInvoice($id)`

**Process:**
1. **Validation** - Check if already converted
2. **Create Invoice** - Copy all data from purchase order
3. **Copy Items** - Transfer all line items
4. **Update Stock** - Increase quantity for each item
5. **Update Bank** - Decrease balance if payment made
6. **Create Transaction** - Record bank transaction
7. **Mark Converted** - Update purchase order status

**Response:**
```json
{
  "success": true,
  "message": "Purchase order converted to invoice successfully",
  "data": {
    "invoice_id": 123,
    "invoice_number": "PI-000123"
  }
}
```

### 2. Stock Update Logic

```php
// Increase stock for purchase
$item->stock_quantity = ($item->stock_quantity ?? 0) + $orderItem->quantity;
```

### 3. Bank Balance Update Logic

```php
// Decrease balance for purchase (money out)
$paymentAmount = $order->payment_amount ?? $totalAmount;
$bankAccount->balance = ($bankAccount->balance ?? 0) - $paymentAmount;
```

### 4. Bank Transaction Record

```php
BankTransaction::create([
    'bank_account_id' => $order->bank_account_id,
    'organization_id' => $order->organization_id,
    'transaction_type' => 'debit',
    'amount' => $paymentAmount,
    'transaction_date' => now()->format('Y-m-d'),
    'description' => "Purchase Invoice #{$invoice->invoice_number} (Converted from PO #{$order->po_number})",
    'reference_type' => 'purchase_invoice',
    'reference_id' => $invoice->id,
]);
```

## Frontend Implementation

### 1. Purchase Order Service

**New Method:** `convertToInvoice(int id)`

```dart
Future<Map<String, dynamic>> convertToInvoice(int id) async {
  final response = await _apiClient.post('/purchase-orders/$id/convert-to-invoice', {});
  return _apiClient.handleResponse(response);
}
```

### 2. Purchase Order Model

**New Fields:**
- `convertedToInvoice` (bool?)
- `purchaseInvoiceId` (int?)
- `convertedAt` (DateTime?)

### 3. Purchase Orders Screen

**New Features:**
- Added "Actions" column to table
- "Convert to Invoice" button (green)
- Shows "Converted" badge if already converted
- Confirmation dialog before conversion
- Loading indicator during conversion
- Success/error messages

**Button Logic:**
```dart
if (order.status != 'converted' && !(order.convertedToInvoice ?? false))
  ElevatedButton.icon(
    onPressed: () => _convertToInvoice(order),
    icon: const Icon(Icons.receipt_long, size: 16),
    label: const Text('Convert to Invoice'),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
    ),
  )
else
  Container(
    child: const Text('Converted', style: TextStyle(color: Colors.grey)),
  )
```

## User Flow

### Step 1: View Purchase Orders
1. Navigate to Purchase Orders screen
2. See list of all purchase orders
3. Each row has "Convert to Invoice" button (if not converted)

### Step 2: Convert to Invoice
1. Click "Convert to Invoice" button
2. Confirmation dialog appears with details:
   - "Convert Purchase Order PO-000001 to Purchase Invoice?"
   - Lists what will happen (stock, bank, status)
3. Click "Convert" to proceed or "Cancel" to abort

### Step 3: Processing
1. Loading indicator shows
2. Backend creates invoice
3. Stock quantities updated
4. Bank balance updated (if payment made)
5. Purchase order marked as converted

### Step 4: Success
1. Success message: "Purchase order converted successfully! Invoice #PI-000123"
2. Button changes to "Converted" badge (gray, disabled)
3. Order status changes to "converted"
4. Table refreshes automatically

## Confirmation Dialog

```
┌─────────────────────────────────────────────┐
│ Convert to Purchase Invoice                 │
├─────────────────────────────────────────────┤
│                                             │
│ Are you sure you want to convert Purchase   │
│ Order PO-000001 to a Purchase Invoice?      │
│                                             │
│ This will:                                  │
│ • Create a new purchase invoice             │
│ • Update stock quantities                   │
│ • Update bank account balance (if payment)  │
│ • Mark this order as converted              │
│                                             │
├─────────────────────────────────────────────┤
│              [Cancel]  [Convert]            │
└─────────────────────────────────────────────┘
```

## Table View

```
┌──────────────────────────────────────────────────────────────────────────────┐
│ Date       │ PO Number  │ Party    │ Valid Till │ Amount   │ Status  │ Actions│
├──────────────────────────────────────────────────────────────────────────────┤
│ 13 Dec 2025│ PO-000001  │ ABC Ltd  │ 20 Dec 2025│ ₹1180.00 │ Pending │ [Convert to Invoice] [Edit] │
│ 12 Dec 2025│ PO-000002  │ XYZ Corp │ 19 Dec 2025│ ₹2500.00 │ Converted│ [Converted] [Edit] │
└──────────────────────────────────────────────────────────────────────────────┘
```

## Business Logic

### Stock Update
- **Purchase Order → Invoice:** Stock INCREASES
- Formula: `new_stock = current_stock + order_quantity`
- Example: Current stock = 100, Order qty = 50 → New stock = 150

### Bank Balance Update
- **Purchase Order → Invoice:** Balance DECREASES (money out)
- Formula: `new_balance = current_balance - payment_amount`
- Example: Current balance = ₹10,000, Payment = ₹1,180 → New balance = ₹8,820

### Payment Modes
- **Cash:** No bank account update (cash transaction)
- **Card/UPI/Bank Transfer:** Bank account balance decreases

## Files Modified

### Backend
1. **backend/database/migrations/2025_12_13_130000_add_conversion_fields_to_purchase_orders.php**
   - New migration for conversion fields

2. **backend/app/Http/Controllers/PurchaseOrderController.php**
   - Added `convertToInvoice($id)` method
   - Complete conversion logic with transactions

3. **backend/routes/api.php**
   - Added route: `POST /api/purchase-orders/{id}/convert-to-invoice`

### Frontend
1. **flutter_app/lib/services/purchase_order_service.dart**
   - Added `convertToInvoice(int id)` method

2. **flutter_app/lib/models/purchase_order_model.dart**
   - Added `convertedToInvoice`, `purchaseInvoiceId`, `convertedAt` fields

3. **flutter_app/lib/screens/user/purchase_orders_screen.dart**
   - Added "Actions" column
   - Added "Convert to Invoice" button
   - Added `_convertToInvoice()` method
   - Added confirmation dialog
   - Added loading and success/error handling

## Testing Guide

### Test Case 1: Convert Purchase Order
1. Create a purchase order with items
2. Go to Purchase Orders screen
3. Click "Convert to Invoice" button
4. Confirm in dialog
5. Verify: Success message appears
6. Verify: Button changes to "Converted"
7. Check Purchase Invoices screen - new invoice created
8. Check Items screen - stock quantities increased
9. Check Cash & Bank - balance decreased (if payment made)

### Test Case 2: Already Converted Order
1. Try to convert an already converted order
2. Verify: Button shows "Converted" (disabled)
3. Verify: Cannot convert again

### Test Case 3: Stock Update
1. Note item stock before conversion: 100 units
2. Create PO with 50 units of that item
3. Convert to invoice
4. Verify: Item stock = 150 units

### Test Case 4: Bank Balance Update
1. Note bank balance before conversion: ₹10,000
2. Create PO with payment ₹1,180 (Card/UPI/Bank Transfer)
3. Convert to invoice
4. Verify: Bank balance = ₹8,820
5. Verify: Bank transaction created with description

### Test Case 5: Cash Payment (No Bank Update)
1. Create PO with payment mode "Cash"
2. Convert to invoice
3. Verify: Bank balance unchanged
4. Verify: No bank transaction created

### Test Case 6: Multiple Items
1. Create PO with 3 different items
2. Convert to invoice
3. Verify: All 3 items' stock increased
4. Verify: Invoice has all 3 items

## Error Handling

### Already Converted
```json
{
  "success": false,
  "message": "This purchase order has already been converted to an invoice"
}
```

### Database Error
```json
{
  "success": false,
  "message": "Failed to convert purchase order: [error details]"
}
```

### Frontend Error Display
- Shows red snackbar with error message
- Closes loading dialog
- Does not refresh table
- User can try again

## Status: ✅ COMPLETE

All conversion functionality has been implemented:
- ✅ Database migration for conversion fields
- ✅ Backend API endpoint for conversion
- ✅ Stock quantity updates (increase)
- ✅ Bank balance updates (decrease)
- ✅ Bank transaction records
- ✅ Purchase order status update
- ✅ Frontend service method
- ✅ Frontend model updates
- ✅ UI button and confirmation dialog
- ✅ Success/error handling
- ✅ Loading indicators

## Next Steps

1. **Run Migration:**
   ```bash
   cd backend
   php artisan migrate
   ```

2. **Restart Backend:**
   ```bash
   php artisan serve
   ```

3. **Hot Restart Flutter App**

4. **Test Conversion:**
   - Create a purchase order
   - Convert to invoice
   - Verify stock and bank updates

The complete Purchase Order → Purchase Invoice conversion flow is now ready for use!
