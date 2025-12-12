# Testing Edit Items Loading

## Debug Steps

### 1. Check Backend API Response

Test the API directly to see if items are returned:

```bash
# Replace {id} with an actual quotation ID
curl http://localhost:8000/api/quotations/{id} \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "X-Organization-Id: YOUR_ORG_ID"
```

Expected response should include:
```json
{
  "id": 1,
  "quotation_number": "QT-001",
  "items": [
    {
      "id": 1,
      "item_id": 5,
      "item_name": "Product Name",
      "quantity": 10,
      "price_per_unit": 100,
      ...
    }
  ]
}
```

### 2. Check Flutter Debug Logs

I've added debug logging to the quotation screen. When you click Edit, check the console for:

```
📦 Quotation loaded: QT-001
📦 Items count: 3
  - Item: Product A, Qty: 10, Price: 100
  - Item: Product B, Qty: 5, Price: 200
  - Item: Product C, Qty: 2, Price: 500
```

### 3. Common Issues & Solutions

#### Issue 1: Items count is 0
**Cause:** Backend not returning items or items not saved
**Solution:** 
- Check if quotation has items in database
- Verify backend relationship is working
- Test API endpoint directly

#### Issue 2: Items count > 0 but not displaying
**Cause:** UI not rendering items list
**Solution:**
- Check if `_quotationItems` list is being updated
- Verify items are being added to the list in setState
- Check if items table widget is rendering the list

#### Issue 3: Error parsing items
**Cause:** JSON structure mismatch
**Solution:**
- Check API response format
- Verify QuotationItem.fromJson matches API structure
- Look for parsing errors in console

### 4. Manual Test Steps

1. **Create a new quotation with items**
   - Go to Quotations screen
   - Click "Create Quotation"
   - Add party
   - Add 2-3 items
   - Save

2. **Edit the quotation**
   - Click the Edit button on the quotation you just created
   - Check if items appear in the items table
   - Check console for debug logs

3. **Verify data**
   - Items should show with correct names, quantities, prices
   - Total amount should match
   - All fields should be editable

### 5. Quick Fix if Items Still Don't Show

If items count shows > 0 in logs but don't display:

**Check the items list variable name:**
```dart
// In create_quotation_screen.dart
List<QuotationItem> _quotationItems = [];

// Make sure setState updates this:
setState(() {
  _quotationItems = quotation.items!.map(...).toList();
});

// Make sure the UI renders this:
..._quotationItems.map((item) => _buildItemRow(item))
```

### 6. Backend Verification

Check database directly:
```sql
-- Check if quotation has items
SELECT * FROM quotation_items WHERE quotation_id = 1;

-- Check if items are linked properly
SELECT qi.*, i.item_name 
FROM quotation_items qi
LEFT JOIN items i ON qi.item_id = i.id
WHERE qi.quotation_id = 1;
```

### 7. Test All 3 Working Screens

- [ ] Quotations - Edit and check items load
- [ ] Sales Invoices - Edit and check items load
- [ ] Sales Returns - Edit and check items load

## Expected Behavior

When you click Edit on any of these 3 screens:
1. Screen opens with all fields populated
2. Items table shows all items with:
   - Item name
   - Quantity
   - Price per unit
   - Discount
   - Tax
   - Line total
3. Total amounts calculate correctly
4. You can modify items and save

## If Still Not Working

Please provide:
1. Debug console output (the 📦 logs)
2. Which screen you're testing (Quotations/Sales Invoices/Sales Returns)
3. Whether you're testing with a newly created record or an old one
4. Any error messages in console

This will help identify the exact issue!
