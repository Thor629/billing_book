# Discount & Round Off Implementation Plan

## Screens Found

### Screens with Discount/Round Off Features

1. **create_sales_invoice_screen.dart**
   - ✅ Has discount per item (functional)
   - ❌ "Add Discount" button (not functional)
   - ✅ Auto Round Off checkbox (functional)

2. **create_quotation_screen.dart**
   - ✅ Has discount per item (functional)
   - ✅ "Add Discount" button (ALREADY FUNCTIONAL)
   - ✅ Auto Round Off checkbox (functional)

3. **create_sales_return_screen.dart**
   - ❌ "Add Discount" button (not functional)
   - ❌ Auto Round Off checkbox (not functional)

4. **create_purchase_return_screen.dart**
   - ❌ Auto Round Off checkbox (not functional)

5. **create_credit_note_screen.dart**
   - ❌ "Add Discount" button (not functional)
   - ❌ Auto Round Off checkbox (not functional)

## Implementation Needed

### 1. Sales Invoice - Add Discount Button
- Add overall discount field
- Create discount dialog
- Update total calculation

### 2. Sales Return - Add Discount & Round Off
- Add discount dialog
- Add round off calculation
- Update total calculation

### 3. Purchase Return - Round Off
- Add round off calculation
- Update total calculation

### 4. Credit Note - Add Discount & Round Off
- Add discount dialog
- Add round off calculation
- Update total calculation

## Implementation Strategy

For each screen:
1. Add state variables for discount and round off
2. Create dialog methods (copy from quotation screen)
3. Update total calculation getters
4. Connect buttons to dialog methods
5. Update save/submit data to include new fields
