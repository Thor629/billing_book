# POS Billing - Setup Complete ✅

## Migration Completed
✅ Barcode column added to items table successfully!

## Database Structure

### Items Table Columns
- `id` - Primary key
- `organization_id` - Foreign key
- `item_name` - Product name
- `item_code` - Unique code
- `barcode` - Barcode (NEW - just added)
- `selling_price` - Selling price
- `purchase_price` - Purchase price
- `mrp` - Maximum retail price
- `stock_qty` - Current stock
- `unit` - Unit of measurement
- `low_stock_alert` - Low stock threshold
- `category` - Product category
- `description` - Product description
- `hsn_code` - HSN code for GST
- `gst_rate` - GST percentage
- `is_active` - Active status
- `created_at` - Creation timestamp
- `updated_at` - Update timestamp

## Backend API Endpoints

### 1. Search Items
```
GET /api/pos/search-items
Parameters:
  - organization_id (required)
  - search (required, min 1 char)
```

**Example:**
```
GET /api/pos/search-items?organization_id=1&search=laptop
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "item_name": "Laptop Dell",
      "item_code": "LAP001",
      "barcode": "1234567890",
      "selling_price": "45000.00",
      "purchase_price": "40000.00",
      "mrp": "50000.00",
      "gst_rate": "18.00",
      "hsn_code": "8471",
      "unit": "PCS",
      "stock_qty": 10,
      "low_stock_alert": 5
    }
  ]
}
```

### 2. Get Item by Barcode
```
GET /api/pos/item-by-barcode
Parameters:
  - organization_id (required)
  - barcode (required)
```

### 3. Save Bill
```
POST /api/pos/save-bill
Body: {
  "organization_id": 1,
  "items": [
    {
      "item_id": 1,
      "quantity": 2,
      "selling_price": 45000,
      "gst_rate": 18
    }
  ],
  "discount": 1000,
  "additional_charge": 500,
  "payment_method": "cash",
  "received_amount": 90000,
  "is_cash_sale": true
}
```

## Testing the POS System

### Step 1: Add Test Items
First, make sure you have some items in your database. You can add them through the Items screen or directly in the database:

```sql
INSERT INTO items (organization_id, item_name, item_code, barcode, selling_price, purchase_price, mrp, stock_qty, unit, gst_rate, is_active, created_at, updated_at)
VALUES 
(1, 'Laptop Dell Inspiron', 'LAP001', '1234567890123', 45000.00, 40000.00, 50000.00, 10, 'PCS', 18.00, 1, NOW(), NOW()),
(1, 'Mouse Wireless', 'MOU001', '9876543210987', 500.00, 400.00, 600.00, 50, 'PCS', 18.00, 1, NOW(), NOW()),
(1, 'Keyboard Mechanical', 'KEY001', '5555555555555', 2500.00, 2000.00, 3000.00, 25, 'PCS', 18.00, 1, NOW(), NOW());
```

### Step 2: Test Search Functionality

1. **Open POS Billing Screen**
   - Navigate to POS Billing from the sidebar

2. **Test Search**
   - Type "laptop" in the search box
   - You should see matching items appear in a dropdown
   - Each item shows:
     - Item name
     - Item code and price
     - Stock quantity (color-coded: green if available, red if low/out)

3. **Add Item to Bill**
   - Click on any search result
   - Item should be added to the billing table
   - Search box should clear
   - Dropdown should close

### Step 3: Test Bill Management

1. **Add Multiple Items**
   - Search and add 2-3 different items
   - Verify each item appears in the table

2. **Modify Quantities**
   - Click the + button to increase quantity
   - Click the - button to decrease quantity
   - Verify totals update automatically

3. **Change Price**
   - Click on the selling price (blue underlined)
   - Enter a new price
   - Click Update
   - Verify total updates

4. **Delete Item**
   - Click the delete icon (red trash)
   - Item should be removed from bill

### Step 4: Test Calculations

1. **Add Discount**
   - Enter a discount amount (e.g., 100)
   - Verify total amount decreases

2. **Add Additional Charge**
   - Enter additional charge (e.g., 50)
   - Verify total amount increases

3. **Enter Received Amount**
   - Enter amount received from customer
   - If more than total, "Change to Return" should appear in orange

### Step 5: Test Bill Saving

1. **Complete a Bill**
   - Add items
   - Enter received amount
   - Select payment method (Cash/Card/UPI/Cheque)

2. **Save Bill**
   - Click "Save Bill [F7]"
   - Should show loading indicator
   - Success message should appear with invoice number
   - Bill should reset to empty state

3. **Verify in Database**
   ```sql
   -- Check sales invoice
   SELECT * FROM sales_invoices ORDER BY id DESC LIMIT 1;
   
   -- Check invoice items
   SELECT * FROM sales_invoice_items WHERE sales_invoice_id = (SELECT MAX(id) FROM sales_invoices);
   
   -- Check stock was reduced
   SELECT item_name, stock_qty FROM items WHERE id IN (SELECT item_id FROM sales_invoice_items WHERE sales_invoice_id = (SELECT MAX(id) FROM sales_invoices));
   ```

## Troubleshooting

### Issue: Search not working
**Solution:**
1. Check if backend is running: `php artisan serve`
2. Check API URL in `app_config.dart`
3. Check browser console for errors
4. Verify organization is selected

### Issue: Items not appearing
**Solution:**
1. Check if items exist in database
2. Verify `is_active = 1`
3. Check `organization_id` matches
4. Check item has stock (`stock_qty > 0`)

### Issue: Bill not saving
**Solution:**
1. Check backend logs: `backend/storage/logs/laravel.log`
2. Verify all required fields are filled
3. Check database connection
4. Ensure items have valid IDs

### Issue: Stock not updating
**Solution:**
1. Check if transaction is committing
2. Verify item IDs are correct
3. Check database permissions

## API Testing with Postman/Thunder Client

### Test Search
```
GET http://localhost:8000/api/pos/search-items?organization_id=1&search=laptop
Headers:
  Authorization: Bearer YOUR_TOKEN
  Accept: application/json
```

### Test Save Bill
```
POST http://localhost:8000/api/pos/save-bill
Headers:
  Authorization: Bearer YOUR_TOKEN
  Accept: application/json
  Content-Type: application/json
Body:
{
  "organization_id": 1,
  "items": [
    {
      "item_id": 1,
      "quantity": 2,
      "selling_price": 45000,
      "gst_rate": 18
    }
  ],
  "discount": 0,
  "additional_charge": 0,
  "payment_method": "cash",
  "received_amount": 106200,
  "is_cash_sale": true
}
```

## Next Steps

1. ✅ Database migration complete
2. ✅ Backend API ready
3. ✅ Frontend integrated
4. 🔄 Test with real data
5. 📱 Add barcode scanner support
6. 🖨️ Add receipt printing
7. 💾 Add hold/resume bills feature

## Status
✅ **POS Billing System is Ready to Use!**

The search functionality is now fully operational and connected to your database. Start adding items and testing the complete flow!
