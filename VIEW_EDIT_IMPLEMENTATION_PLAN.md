# View/Edit Functionality Implementation Plan

## Screens Needing View/Edit Functionality

### 1. **Quotations Screen** ✅ Has buttons but empty handlers
- Add `_viewQuotation()` method
- Add `_editQuotation()` method  
- Add `_deleteQuotation()` method

### 2. **Payment In Screen** ✅ Has buttons but empty handlers
- Add `_viewPayment()` method
- Add `_editPayment()` method
- Add `_deletePayment()` method

### 3. **Expenses Screen** ❌ Missing action buttons
- Add action column with view/edit/delete buttons
- Add `_viewExpense()` method
- Add `_editExpense()` method
- Add `_deleteExpense()` method

### 4. **Sales Return Screen** ⚠️ Has view/delete, missing edit
- Add `_editReturn()` method

### 5. **Credit Note Screen** - Need to check
### 6. **Debit Note Screen** - Need to check
### 7. **Delivery Challan Screen** - Need to check

## Backend API Endpoints Needed

### GET endpoints for single records:
- `GET /api/quotations/{id}` - Get single quotation
- `GET /api/payment-in/{id}` - Get single payment in
- `GET /api/expenses/{id}` - Get single expense
- `GET /api/sales-returns/{id}` - Get single sales return
- `GET /api/purchase-invoices/{id}` - Get single purchase invoice
- `GET /api/purchase-returns/{id}` - Get single purchase return

### UPDATE endpoints:
- `PUT /api/quotations/{id}` - Update quotation
- `PUT /api/payment-in/{id}` - Update payment in
- `PUT /api/expenses/{id}` - Update expense
- `PUT /api/sales-returns/{id}` - Update sales return
- `PUT /api/purchase-invoices/{id}` - Update purchase invoice
- `PUT /api/purchase-returns/{id}` - Update purchase return

## Implementation Steps

1. Update frontend screens with proper handlers
2. Add backend API endpoints
3. Update service classes
4. Make create screens work in edit mode
5. Test all functionality
