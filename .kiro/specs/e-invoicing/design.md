# E-Invoicing Feature Design Document

## Overview

The e-invoicing feature extends the existing sales invoice functionality to support automatic GST-compliant e-invoice generation, IRN-based way bill creation, and GSTR1 reconciliation. The system integrates with the Government of India's GST e-invoice API to generate legally valid electronic invoices with QR codes and Invoice Reference Numbers (IRN).

The feature builds upon the existing invoice creation screen and adds:
- Party selection from existing parties database
- Automatic e-invoice generation with IRN
- QR code generation for invoice verification
- Way bill generation using IRN
- GSTR1 reconciliation and export
- Enhanced invoice management with draft and final states

## Architecture

### System Components

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter Frontend                         │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Create Invoice Screen                                │  │
│  │  - Party Selection Dialog                             │  │
│  │  - Item Selection Dialog                              │  │
│  │  - Invoice Form with Calculations                     │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Invoice List Screen                                  │  │
│  │  - Filter by status, date, party                      │  │
│  │  - View/Edit/Delete invoices                          │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  GSTR1 Reconciliation Screen                          │  │
│  │  - Date range selection                               │  │
│  │  - Export to GSTR1 format                             │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ HTTP/REST API
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                     Laravel Backend                          │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Sales Invoice Controller                             │  │
│  │  - CRUD operations                                    │  │
│  │  - Invoice number generation                          │  │
│  │  - Payment recording                                  │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  E-Invoice Service                                    │  │
│  │  - GST API integration                                │  │
│  │  - IRN generation                                     │  │
│  │  - QR code generation                                 │  │
│  │  - Way bill generation                                │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  GSTR1 Service                                        │  │
│  │  - Data aggregation                                   │  │
│  │  - Export formatting                                  │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ HTTPS/REST API
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              GST E-Invoice API (Government)                  │
│  - E-Invoice Generation                                      │
│  - IRN Assignment                                            │
│  - Way Bill Generation                                       │
│  - Invoice Cancellation                                      │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

1. **Invoice Creation Flow**:
   - User selects party → Frontend fetches party details
   - User adds items → Frontend calculates totals
   - User clicks Save → Backend validates and stores invoice
   - Backend triggers e-invoice generation → GST API returns IRN
   - Backend generates QR code → Frontend displays success

2. **Way Bill Generation Flow**:
   - User clicks "Generate Way Bill" → Backend sends IRN to GST API
   - GST API returns way bill number → Backend stores with invoice
   - Frontend displays way bill for download/print

3. **GSTR1 Reconciliation Flow**:
   - User selects date range → Backend fetches all e-invoices
   - User clicks Export → Backend formats data for GSTR1
   - Frontend downloads formatted file

## Components and Interfaces

### Frontend Components

#### 1. Party Selection Dialog
**Purpose**: Allow users to search and select parties from existing database

**Props**:
- `onPartySelected: (PartyModel party) => void` - Callback when party is selected
- `organizationId: int` - Current organization ID for filtering parties

**State**:
- `parties: List<PartyModel>` - List of all parties
- `filteredParties: List<PartyModel>` - Filtered list based on search
- `searchQuery: String` - Current search text
- `isLoading: bool` - Loading state

**Methods**:
- `loadParties()` - Fetch parties from API
- `filterParties(String query)` - Filter parties by name/phone
- `selectParty(PartyModel party)` - Handle party selection

#### 2. Item Selection Dialog
**Purpose**: Allow users to search and select items to add to invoice

**Props**:
- `onItemSelected: (ItemModel item, double quantity) => void` - Callback when item is selected
- `organizationId: int` - Current organization ID

**State**:
- `items: List<ItemModel>` - List of all items
- `filteredItems: List<ItemModel>` - Filtered list
- `searchQuery: String` - Search text
- `selectedItem: ItemModel?` - Currently selected item
- `quantity: double` - Quantity to add

**Methods**:
- `loadItems()` - Fetch items from API
- `filterItems(String query)` - Filter by name/code/barcode
- `addItem()` - Add item with quantity to invoice

#### 3. Invoice Form Component
**Purpose**: Main form for creating/editing invoices

**State**:
- `selectedParty: PartyModel?` - Selected party
- `invoiceItems: List<InvoiceItemRow>` - List of invoice line items
- `invoiceDate: DateTime` - Invoice date
- `dueDate: DateTime` - Payment due date
- `subtotal: double` - Sum of all line totals
- `discountAmount: double` - Total discount
- `taxAmount: double` - Total tax
- `additionalCharges: double` - Extra charges
- `roundOff: double` - Round off amount
- `totalAmount: double` - Final total
- `amountReceived: double` - Payment received
- `balanceAmount: double` - Outstanding balance
- `notes: String?` - Custom notes
- `termsConditions: String?` - Terms and conditions

**Methods**:
- `selectParty()` - Open party selection dialog
- `addItem()` - Open item selection dialog
- `removeItem(int index)` - Remove item from list
- `calculateTotals()` - Recalculate all amounts
- `saveInvoice()` - Validate and save invoice
- `saveAndNew()` - Save and open new form

#### 4. Invoice Item Row Component
**Purpose**: Represent a single line item in the invoice

**Props**:
- `item: InvoiceItemRow` - Item data
- `onChanged: (InvoiceItemRow updated) => void` - Callback when values change
- `onRemove: () => void` - Callback to remove item

**State**:
- `quantity: double` - Item quantity
- `pricePerUnit: double` - Unit price
- `discountPercent: double` - Discount percentage
- `taxPercent: double` - Tax percentage
- `lineTotal: double` - Calculated line total

**Methods**:
- `calculateLineTotal()` - Calculate total for this line
- `updateQuantity(double qty)` - Update quantity and recalculate
- `updatePrice(double price)` - Update price and recalculate
- `updateDiscount(double discount)` - Update discount and recalculate

### Backend Services

#### 1. SalesInvoiceController
**Endpoints**:
- `GET /api/sales-invoices` - List invoices with filters
- `GET /api/sales-invoices/{id}` - Get single invoice
- `POST /api/sales-invoices` - Create new invoice
- `PUT /api/sales-invoices/{id}` - Update invoice
- `DELETE /api/sales-invoices/{id}` - Delete invoice
- `GET /api/sales-invoices/next-number` - Get next invoice number
- `POST /api/sales-invoices/{id}/generate-einvoice` - Generate e-invoice
- `POST /api/sales-invoices/{id}/generate-waybill` - Generate way bill

**Methods**:
- `index(Request $request)` - List with pagination and filters
- `store(Request $request)` - Create and optionally generate e-invoice
- `update(Request $request, $id)` - Update invoice (draft only)
- `destroy($id)` - Soft delete invoice
- `generateEInvoice($id)` - Trigger e-invoice generation
- `generateWayBill($id)` - Generate way bill using IRN

#### 2. EInvoiceService
**Purpose**: Handle GST e-invoice API integration

**Methods**:
- `generateEInvoice(SalesInvoice $invoice): array` - Generate e-invoice and return IRN
- `generateQRCode(string $irn, array $invoiceData): string` - Generate QR code image
- `cancelEInvoice(string $irn, string $reason): bool` - Cancel e-invoice
- `getEInvoiceDetails(string $irn): array` - Fetch e-invoice from GST
- `generateWayBill(string $irn, array $transportDetails): array` - Generate way bill

**GST API Integration**:
```php
// E-Invoice Generation Request
POST https://gst-api.gov.in/einvoice/v1.03/generate
Headers:
  - Authorization: Bearer {access_token}
  - Content-Type: application/json

Body:
{
  "Version": "1.1",
  "TranDtls": {
    "TaxSch": "GST",
    "SupTyp": "B2B",
    "RegRev": "N"
  },
  "DocDtls": {
    "Typ": "INV",
    "No": "INV001",
    "Dt": "01/12/2024"
  },
  "SellerDtls": {
    "Gstin": "29AABCT1332L000",
    "LglNm": "Company Name",
    "Addr1": "Address Line 1",
    "Loc": "City",
    "Pin": 560001,
    "Stcd": "29"
  },
  "BuyerDtls": {
    "Gstin": "29AABCT1332L001",
    "LglNm": "Buyer Name",
    "Pos": "29",
    "Addr1": "Buyer Address",
    "Loc": "City",
    "Pin": 560002,
    "Stcd": "29"
  },
  "ItemList": [
    {
      "SlNo": "1",
      "PrdDesc": "Product Description",
      "IsServc": "N",
      "HsnCd": "1001",
      "Qty": 10,
      "Unit": "PCS",
      "UnitPrice": 100,
      "TotAmt": 1000,
      "Discount": 0,
      "AssAmt": 1000,
      "GstRt": 18,
      "IgstAmt": 180,
      "CgstAmt": 0,
      "SgstAmt": 0,
      "TotItemVal": 1180
    }
  ],
  "ValDtls": {
    "AssVal": 1000,
    "IgstVal": 180,
    "CgstVal": 0,
    "SgstVal": 0,
    "TotInvVal": 1180
  }
}

Response:
{
  "success": true,
  "Irn": "ad23b5d87f890e0987654321abcdef1234567890abcdef1234567890abcdef12",
  "AckNo": "112010017754924",
  "AckDt": "2024-12-01 10:30:00",
  "SignedInvoice": "...",
  "SignedQRCode": "..."
}
```

#### 3. GSTR1Service
**Purpose**: Handle GSTR1 reconciliation and export

**Methods**:
- `getInvoicesForGSTR1(DateTime $startDate, DateTime $endDate): Collection` - Fetch invoices
- `exportToGSTR1Format(Collection $invoices): string` - Format for GSTR1
- `markAsReconciled(array $invoiceIds): void` - Mark invoices as reconciled

## Data Models

### Enhanced SalesInvoice Model

```dart
class SalesInvoice {
  // Existing fields...
  
  // E-Invoice specific fields
  final String? irn;                    // Invoice Reference Number
  final String? ackNo;                  // Acknowledgement Number
  final DateTime? ackDate;              // Acknowledgement Date
  final String? qrCodeData;             // QR Code data string
  final String? qrCodeImage;            // QR Code image URL/base64
  final String? signedInvoice;          // Digitally signed invoice
  final String? wayBillNo;              // Way bill number
  final DateTime? wayBillDate;          // Way bill generation date
  final String invoiceStatus;           // draft, final, cancelled
  final bool isEInvoiceGenerated;       // E-invoice generation flag
  final bool isReconciled;              // GSTR1 reconciliation flag
  final DateTime? reconciledAt;         // Reconciliation date
  
  // ... rest of the model
}
```

### Database Schema Updates

```sql
-- Add columns to sales_invoices table
ALTER TABLE sales_invoices ADD COLUMN irn VARCHAR(64) NULL;
ALTER TABLE sales_invoices ADD COLUMN ack_no VARCHAR(20) NULL;
ALTER TABLE sales_invoices ADD COLUMN ack_date TIMESTAMP NULL;
ALTER TABLE sales_invoices ADD COLUMN qr_code_data TEXT NULL;
ALTER TABLE sales_invoices ADD COLUMN qr_code_image TEXT NULL;
ALTER TABLE sales_invoices ADD COLUMN signed_invoice TEXT NULL;
ALTER TABLE sales_invoices ADD COLUMN way_bill_no VARCHAR(20) NULL;
ALTER TABLE sales_invoices ADD COLUMN way_bill_date TIMESTAMP NULL;
ALTER TABLE sales_invoices ADD COLUMN invoice_status VARCHAR(20) DEFAULT 'draft';
ALTER TABLE sales_invoices ADD COLUMN is_einvoice_generated BOOLEAN DEFAULT FALSE;
ALTER TABLE sales_invoices ADD COLUMN is_reconciled BOOLEAN DEFAULT FALSE;
ALTER TABLE sales_invoices ADD COLUMN reconciled_at TIMESTAMP NULL;

-- Create index for IRN lookups
CREATE INDEX idx_sales_invoices_irn ON sales_invoices(irn);
CREATE INDEX idx_sales_invoices_status ON sales_invoices(invoice_status);
```



## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Party selection populates invoice fields
*For any* party selected from the parties list, the invoice form should be populated with that party's billing address, GST number, contact details, and shipping address
**Validates: Requirements 1.3**

### Property 2: Item addition triggers calculation
*For any* item added to an invoice with valid quantity, price, discount, and tax values, the system should calculate the correct line total
**Validates: Requirements 2.5**

### Property 3: Invoice total calculation accuracy
*For any* invoice with multiple items, discounts, taxes, and additional charges, the final total amount should equal the sum of all line totals minus discounts plus taxes plus additional charges plus round-off
**Validates: Requirements 3.1, 3.2, 3.3, 3.4**

### Property 4: Balance amount calculation
*For any* invoice with a total amount and payment received, the balance amount should equal total amount minus amount received
**Validates: Requirements 3.5**

### Property 5: E-invoice generation with valid GST
*For any* invoice with a GST-registered party and valid invoice data, when e-invoice generation is triggered, the system should receive an IRN from the GST system
**Validates: Requirements 4.1, 4.2**

### Property 6: QR code generation with IRN
*For any* invoice with a valid IRN, the system should generate a QR code containing the invoice details
**Validates: Requirements 4.3**

### Property 7: Way bill requires IRN
*For any* invoice, way bill generation should only be possible if a valid IRN exists
**Validates: Requirements 5.1, 5.2**

### Property 8: GSTR1 export includes all e-invoices
*For any* date range selected, the GSTR1 export should include all invoices with e-invoices generated within that range
**Validates: Requirements 6.1, 6.2, 6.3**

### Property 9: Invoice number auto-increment
*For any* saved invoice, the next invoice number should be one greater than the current invoice number
**Validates: Requirements 10.5**

### Property 10: Draft invoices are editable
*For any* invoice with status "draft", all fields should be editable
**Validates: Requirements 15.2**

### Property 11: Final invoices are immutable
*For any* invoice with status "final" and an IRN, no fields should be editable
**Validates: Requirements 15.4, 15.5**

### Property 12: Payment status updates correctly
*For any* invoice, when amount received equals total amount, payment status should be "paid"; when amount received is zero, status should be "unpaid"; otherwise status should be "partially paid"
**Validates: Requirements 9.4**

### Property 13: Discount calculation consistency
*For any* invoice item with a discount percentage, the discount amount should equal (price per unit × quantity × discount percentage / 100)
**Validates: Requirements 2.4**

### Property 14: Tax calculation consistency
*For any* invoice item with a tax percentage, the tax amount should equal ((price per unit × quantity - discount amount) × tax percentage / 100)
**Validates: Requirements 2.5**

### Property 15: Barcode scan increments quantity
*For any* item already in the invoice, scanning its barcode again should increment the quantity by 1 instead of adding a duplicate line
**Validates: Requirements 11.4**

## Error Handling

### Frontend Error Handling

1. **Network Errors**:
   - Display user-friendly error messages
   - Provide retry options
   - Cache form data to prevent loss

2. **Validation Errors**:
   - Highlight invalid fields in red
   - Display specific error messages below fields
   - Prevent form submission until errors are resolved

3. **GST API Errors**:
   - Display GST system error messages
   - Save invoice as draft if e-invoice generation fails
   - Provide option to retry e-invoice generation

4. **Party/Item Not Found**:
   - Display "No results found" message
   - Provide option to create new party/item
   - Clear search and show all results

### Backend Error Handling

1. **Validation Errors**:
   - Return 422 status with detailed error messages
   - Validate all required fields before processing
   - Check data types and formats

2. **GST API Errors**:
   - Log all API requests and responses
   - Return GST error messages to frontend
   - Implement retry logic with exponential backoff
   - Handle timeout errors gracefully

3. **Database Errors**:
   - Use transactions for invoice creation
   - Rollback on any error
   - Log errors for debugging

4. **Authentication Errors**:
   - Return 401 for invalid tokens
   - Return 403 for insufficient permissions
   - Validate organization access

### Error Response Format

```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "party_id": ["Party is required"],
    "items": ["At least one item is required"],
    "invoice_date": ["Invoice date cannot be in the future"]
  }
}
```

## Testing Strategy

### Unit Testing

**Frontend Unit Tests**:
1. Test invoice total calculations with various combinations of items, discounts, and taxes
2. Test balance amount calculation with different payment amounts
3. Test invoice number auto-increment logic
4. Test party selection and form population
5. Test item addition and removal
6. Test discount and tax calculations for individual items
7. Test payment status determination logic
8. Test date calculations for due date based on payment terms

**Backend Unit Tests**:
1. Test SalesInvoiceController CRUD operations
2. Test invoice validation rules
3. Test invoice number generation
4. Test payment recording logic
5. Test GSTR1 data aggregation
6. Test QR code generation
7. Test invoice status transitions (draft → final)
8. Test authorization checks for invoice operations

### Property-Based Testing

The model will use **fast-check** (JavaScript/TypeScript) for Flutter/Dart property-based testing, or **Hypothesis** (Python) for backend testing if needed.

**Property Test 1: Invoice total calculation**
- Generate random invoices with varying numbers of items, discounts, taxes
- Verify total = sum(line totals) - discounts + taxes + charges + roundoff

**Property Test 2: Balance calculation**
- Generate random invoices with random payment amounts
- Verify balance = total - amount received

**Property Test 3: Payment status determination**
- Generate random invoices with various payment amounts
- Verify status is correct based on amount received vs total

**Property Test 4: Invoice number increment**
- Generate sequence of invoices
- Verify each invoice number is previous + 1

**Property Test 5: Discount calculation**
- Generate random items with random discount percentages
- Verify discount amount = (price × qty × discount% / 100)

**Property Test 6: Tax calculation**
- Generate random items with random tax percentages
- Verify tax amount = ((price × qty - discount) × tax% / 100)

### Integration Testing

1. **Invoice Creation Flow**:
   - Create invoice with party and items
   - Verify invoice is saved with correct totals
   - Verify e-invoice generation is triggered
   - Verify IRN is stored

2. **Way Bill Generation Flow**:
   - Create invoice with e-invoice
   - Generate way bill
   - Verify way bill number is stored

3. **GSTR1 Export Flow**:
   - Create multiple invoices
   - Export GSTR1 data
   - Verify all invoices are included
   - Verify format is correct

4. **Payment Recording Flow**:
   - Create invoice
   - Record partial payment
   - Verify balance is updated
   - Record remaining payment
   - Verify status changes to "paid"

### End-to-End Testing

1. Complete invoice creation from party selection to save
2. E-invoice generation and QR code display
3. Way bill generation and download
4. GSTR1 reconciliation and export
5. Invoice editing (draft) and finalization
6. Payment recording and status updates

## Security Considerations

1. **Authentication & Authorization**:
   - All API endpoints require valid authentication token
   - Users can only access invoices for their organization
   - Validate organization_id matches authenticated user

2. **Data Validation**:
   - Validate all input data on backend
   - Sanitize user input to prevent XSS
   - Use parameterized queries to prevent SQL injection

3. **GST API Security**:
   - Store GST API credentials securely (environment variables)
   - Use HTTPS for all GST API calls
   - Implement rate limiting to prevent abuse
   - Log all API interactions for audit trail

4. **Sensitive Data**:
   - Encrypt IRN and signed invoice data at rest
   - Mask GST numbers in logs
   - Implement access controls for financial data

5. **Invoice Integrity**:
   - Prevent editing of finalized invoices
   - Log all invoice modifications
   - Implement soft delete to maintain audit trail

## Performance Considerations

1. **Frontend Performance**:
   - Debounce search inputs (300ms delay)
   - Lazy load party and item lists
   - Cache frequently accessed data
   - Optimize re-renders with React.memo or similar

2. **Backend Performance**:
   - Index database columns used in queries (irn, invoice_number, party_id)
   - Use eager loading for related data (party, items)
   - Implement pagination for invoice lists
   - Cache GST API responses (with appropriate TTL)

3. **GST API Performance**:
   - Implement queue for e-invoice generation
   - Process e-invoices asynchronously
   - Implement retry mechanism with exponential backoff
   - Monitor API rate limits

4. **Database Performance**:
   - Use database transactions for invoice creation
   - Optimize queries with proper indexes
   - Archive old invoices to separate table
   - Regular database maintenance and optimization

## Deployment Considerations

1. **Environment Configuration**:
   - GST API credentials (sandbox vs production)
   - API endpoints (configurable per environment)
   - Feature flags for e-invoice generation

2. **Migration Strategy**:
   - Run database migrations to add new columns
   - Backfill existing invoices with default values
   - Test e-invoice generation in sandbox environment

3. **Monitoring**:
   - Log all GST API interactions
   - Monitor e-invoice generation success rate
   - Alert on GST API failures
   - Track invoice creation metrics

4. **Rollback Plan**:
   - Ability to disable e-invoice generation via feature flag
   - Database migration rollback scripts
   - Fallback to manual invoice generation

## Future Enhancements

1. **Bulk Operations**:
   - Bulk e-invoice generation
   - Bulk way bill generation
   - Bulk invoice export

2. **Advanced Features**:
   - E-invoice cancellation
   - Credit note generation
   - Debit note generation
   - Invoice templates

3. **Reporting**:
   - Invoice analytics dashboard
   - Tax reports
   - Payment collection reports
   - Outstanding invoices report

4. **Integration**:
   - Email invoice to customers
   - WhatsApp invoice sharing
   - SMS notifications
   - Payment gateway integration
