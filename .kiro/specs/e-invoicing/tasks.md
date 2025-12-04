# Implementation Plan

## Overview
This implementation plan breaks down the e-invoicing feature into discrete, manageable tasks. Each task builds incrementally on previous work, ensuring the system remains functional throughout development.

---

- [-] 1. Enhance data models and database schema

  - Add e-invoice specific fields to SalesInvoice model
  - Create database migration for new columns
  - Update model serialization methods
  - _Requirements: 4.2, 4.3, 5.3, 6.3, 15.1_



- [ ] 1.1 Update Flutter SalesInvoice model
  - Add IRN, acknowledgement number, QR code fields
  - Add invoice status, e-invoice flags
  - Add way bill fields
  - Update fromJson and toJson methods


  - _Requirements: 4.2, 4.3, 5.3_

- [ ] 1.2 Create Laravel database migration
  - Add columns: irn, ack_no, ack_date, qr_code_data, qr_code_image
  - Add columns: signed_invoice, way_bill_no, way_bill_date


  - Add columns: invoice_status, is_einvoice_generated, is_reconciled, reconciled_at
  - Create indexes for irn and invoice_status
  - _Requirements: 4.2, 5.3, 6.3, 15.1_

- [ ] 1.3 Update Laravel SalesInvoice model
  - Add new fields to fillable array
  - Add casts for date fields and boolean flags
  - Add accessor methods for computed properties
  - _Requirements: 4.2, 5.3_


- [ ] 1.4 Write property test for invoice model serialization
  - **Property 1: Model round-trip consistency**
  - **Validates: Requirements 4.2**

---




- [ ] 2. Implement party selection functionality
  - Create party selection dialog component
  - Implement party search and filtering
  - Auto-populate invoice fields on party selection
  - _Requirements: 1.1, 1.2, 1.3, 1.4_

- [ ] 2.1 Create PartySelectionDialog widget
  - Design dialog UI with search bar
  - Display party list with name, phone, GST number
  - Implement search functionality with debouncing
  - Handle party selection callback
  - _Requirements: 1.1, 1.2_

- [ ] 2.2 Integrate party selection in invoice form
  - Replace "Add Party" placeholder with party selection trigger
  - Display selected party details in Bill To section
  - Auto-populate billing address, GST number, contact details
  - Handle party change and clear functionality
  - _Requirements: 1.3, 1.4_

- [ ] 2.3 Add "Create New Party" option
  - Add button to create party from invoice screen
  - Open party creation form in dialog
  - Refresh party list after creation
  - Auto-select newly created party
  - _Requirements: 1.5_

- [ ] 2.4 Write property test for party selection
  - **Property 1: Party selection populates invoice fields**
  - **Validates: Requirements 1.3**

---

- [ ] 3. Implement item selection and management
  - Create item selection dialog
  - Implement item search and barcode scanning
  - Add item rows to invoice with calculations
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 11.1, 11.2, 11.3, 11.4_

- [ ] 3.1 Create ItemSelectionDialog widget
  - Design dialog UI with search and barcode scan options
  - Display item list with name, code, HSN/SAC, price
  - Implement search functionality
  - Add quantity input field
  - _Requirements: 2.1, 2.2_

- [ ] 3.2 Implement barcode scanning
  - Integrate barcode scanner library
  - Handle barcode scan event
  - Search item by barcode
  - Auto-add item or increment quantity if exists
  - _Requirements: 11.1, 11.2, 11.3, 11.4_

- [ ] 3.3 Create InvoiceItemRow widget
  - Display item details (name, HSN/SAC, code, MRP)
  - Add input fields for quantity, price, discount, tax
  - Calculate line total on value changes
  - Add remove button
  - _Requirements: 2.3, 2.4, 2.5_

- [ ] 3.4 Implement item list management in invoice form
  - Maintain list of invoice items
  - Handle item addition from dialog
  - Handle item removal
  - Update totals when items change
  - _Requirements: 2.3, 2.5_

- [ ] 3.5 Write property test for item calculations
  - **Property 2: Item addition triggers calculation**
  - **Property 13: Discount calculation consistency**
  - **Property 14: Tax calculation consistency**
  - **Validates: Requirements 2.4, 2.5**

- [ ] 3.6 Write property test for barcode scanning
  - **Property 15: Barcode scan increments quantity**
  - **Validates: Requirements 11.4**

---

- [ ] 4. Implement automatic invoice calculations
  - Calculate subtotal from line items
  - Apply discounts and additional charges
  - Calculate taxes and round-off
  - Calculate balance amount
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 12.1, 12.2, 12.3, 12.4, 12.5_

- [ ] 4.1 Create InvoiceCalculator utility class
  - Method to calculate subtotal from items
  - Method to apply discount (percentage or fixed)
  - Method to calculate tax amounts
  - Method to apply round-off
  - Method to calculate balance
  - _Requirements: 3.1, 3.2, 3.3, 3.4_

- [ ] 4.2 Integrate calculations in invoice form
  - Call calculator on item changes
  - Update all total fields in real-time
  - Handle discount and additional charges
  - Apply auto round-off if enabled
  - _Requirements: 3.1, 3.2, 3.3, 3.4_

- [ ] 4.3 Implement discount and charges dialogs
  - Create dialog for adding discount (percentage/fixed)
  - Create dialog for adding additional charges
  - Update totals when discount/charges change
  - Display discount and charges in totals section
  - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5_

- [ ] 4.4 Implement payment amount handling
  - Add payment amount input field
  - Calculate balance amount automatically
  - Update payment status based on amount
  - Handle "Mark as fully paid" checkbox
  - _Requirements: 3.5, 9.1, 9.2, 9.3, 9.4_

- [ ] 4.5 Write property test for invoice calculations
  - **Property 3: Invoice total calculation accuracy**
  - **Property 4: Balance amount calculation**
  - **Property 12: Payment status updates correctly**
  - **Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 9.4**

---

- [ ] 5. Implement backend invoice CRUD operations
  - Create/update invoice endpoints
  - Implement invoice validation
  - Generate invoice numbers automatically
  - Handle invoice status transitions
  - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5, 15.1, 15.2, 15.3, 15.4, 15.5_

- [ ] 5.1 Enhance SalesInvoiceController store method
  - Validate all required fields
  - Generate next invoice number
  - Create invoice with items
  - Set initial status as "draft"
  - Return created invoice with ID
  - _Requirements: 10.1, 10.2, 10.5_

- [ ] 5.2 Enhance SalesInvoiceController update method
  - Check if invoice is editable (draft status)
  - Validate updated data
  - Update invoice and items
  - Return updated invoice
  - _Requirements: 15.2, 15.4, 15.5_

- [ ] 5.3 Implement invoice number generation
  - Create method to get next invoice number
  - Support custom prefix
  - Handle concurrent requests safely
  - Return formatted invoice number
  - _Requirements: 10.5_

- [ ] 5.4 Implement invoice status management
  - Add method to change status (draft → final)
  - Prevent editing of final invoices
  - Validate status transitions
  - _Requirements: 15.1, 15.3, 15.4_

- [ ] 5.5 Write unit tests for invoice controller
  - Test invoice creation with valid data
  - Test validation errors
  - Test invoice number generation
  - Test status transitions
  - Test edit restrictions on final invoices
  - _Requirements: 10.1, 10.2, 10.5, 15.2, 15.4_

- [ ] 5.6 Write property test for invoice number increment
  - **Property 9: Invoice number auto-increment**
  - **Validates: Requirements 10.5**

---

- [ ] 6. Implement GST e-invoice integration
  - Create EInvoiceService for GST API calls
  - Implement e-invoice generation
  - Generate and store QR codes
  - Handle GST API errors
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 13.1, 13.2, 13.3, 13.4, 13.5, 14.1, 14.2, 14.4_

- [ ] 6.1 Create EInvoiceService class
  - Set up GST API configuration (sandbox/production)
  - Implement authentication with GST API
  - Create method to format invoice data for GST
  - Handle API request/response
  - _Requirements: 13.1, 13.2_

- [ ] 6.2 Implement generateEInvoice method
  - Format invoice data according to GST schema
  - Send request to GST e-invoice API
  - Parse response and extract IRN
  - Store IRN, acknowledgement number, and date
  - Handle API errors and return error messages
  - _Requirements: 4.1, 4.2, 13.2, 13.3, 13.4_

- [ ] 6.3 Implement QR code generation
  - Extract QR code data from GST response
  - Generate QR code image
  - Store QR code data and image with invoice
  - _Requirements: 4.3, 14.1_

- [ ] 6.4 Add generateEInvoice endpoint to controller
  - Create POST /api/sales-invoices/{id}/generate-einvoice
  - Validate invoice is ready for e-invoice
  - Call EInvoiceService
  - Update invoice with IRN and QR code
  - Change status to "final"
  - Return updated invoice
  - _Requirements: 4.1, 4.2, 4.3, 13.5_

- [ ] 6.5 Integrate e-invoice generation in frontend
  - Add "Generate E-Invoice" button
  - Call backend API on button click
  - Display IRN and QR code on success
  - Show error message on failure
  - Update invoice status to final
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 14.1, 14.4_

- [ ] 6.6 Write unit tests for EInvoiceService
  - Test GST API request formatting
  - Test successful e-invoice generation
  - Test error handling
  - Test QR code generation
  - _Requirements: 4.1, 4.2, 4.3, 13.2, 13.3, 13.4_

- [ ] 6.7 Write property test for e-invoice generation
  - **Property 5: E-invoice generation with valid GST**
  - **Property 6: QR code generation with IRN**
  - **Validates: Requirements 4.1, 4.2, 4.3**

---

- [ ] 7. Implement way bill generation
  - Add way bill generation to EInvoiceService
  - Create backend endpoint for way bill
  - Add frontend UI for way bill generation
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [ ] 7.1 Implement generateWayBill method in EInvoiceService
  - Format way bill request with IRN
  - Send request to GST way bill API
  - Parse response and extract way bill number
  - Store way bill number and date
  - _Requirements: 5.2, 5.3_

- [ ] 7.2 Add generateWayBill endpoint to controller
  - Create POST /api/sales-invoices/{id}/generate-waybill
  - Validate invoice has IRN
  - Call EInvoiceService
  - Update invoice with way bill details
  - Return updated invoice
  - _Requirements: 5.1, 5.2, 5.3_

- [ ] 7.3 Add way bill generation UI
  - Add "Generate Way Bill" button (enabled only if IRN exists)
  - Call backend API on button click
  - Display way bill number on success
  - Provide download/print option
  - _Requirements: 5.1, 5.4, 5.5_

- [ ] 7.4 Write unit tests for way bill generation
  - Test way bill API request
  - Test successful generation
  - Test error handling
  - Test IRN validation
  - _Requirements: 5.1, 5.2, 5.3_

- [ ] 7.5 Write property test for way bill generation
  - **Property 7: Way bill requires IRN**
  - **Validates: Requirements 5.1, 5.2**

---

- [ ] 8. Implement GSTR1 reconciliation
  - Create GSTR1Service for data aggregation
  - Implement export functionality
  - Create reconciliation UI
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [ ] 8.1 Create GSTR1Service class
  - Method to fetch invoices by date range
  - Method to aggregate invoice data
  - Method to format data for GSTR1 export
  - Method to mark invoices as reconciled
  - _Requirements: 6.1, 6.2, 6.4_

- [ ] 8.2 Add GSTR1 endpoints to controller
  - Create GET /api/gstr1/invoices?start_date&end_date
  - Create POST /api/gstr1/export
  - Create POST /api/gstr1/mark-reconciled
  - _Requirements: 6.1, 6.3, 6.4, 6.5_

- [ ] 8.3 Create GSTR1ReconciliationScreen
  - Add date range selector
  - Display list of e-invoices with details
  - Add "Export for GSTR1" button
  - Show reconciliation status
  - _Requirements: 6.1, 6.2, 6.3_

- [ ] 8.4 Implement GSTR1 export functionality
  - Format data according to GSTR1 schema
  - Generate downloadable file (JSON/Excel)
  - Mark exported invoices as reconciled
  - _Requirements: 6.4, 6.5_

- [ ] 8.5 Write unit tests for GSTR1Service
  - Test data aggregation
  - Test export formatting
  - Test date range filtering
  - Test reconciliation marking
  - _Requirements: 6.1, 6.2, 6.4, 6.5_

- [ ] 8.6 Write property test for GSTR1 export
  - **Property 8: GSTR1 export includes all e-invoices**
  - **Validates: Requirements 6.1, 6.2, 6.3**

---

- [ ] 9. Implement invoice settings and configuration
  - Create settings screen for invoice configuration
  - Implement default values management
  - Add bank details configuration
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

- [ ] 9.1 Create InvoiceSettingsScreen
  - Add fields for invoice prefix
  - Add field for starting invoice number
  - Add field for default payment terms
  - Add toggle for auto round-off
  - Add bank details section
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

- [ ] 9.2 Create backend settings endpoints
  - Create GET /api/invoice-settings
  - Create PUT /api/invoice-settings
  - Store settings per organization
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

- [ ] 9.3 Apply settings in invoice creation
  - Load settings when creating new invoice
  - Apply default prefix and payment terms
  - Apply auto round-off setting
  - Display bank details if enabled
  - _Requirements: 7.2, 7.3, 7.4, 7.5_

- [ ] 9.4 Write unit tests for settings
  - Test settings CRUD operations
  - Test default value application
  - Test settings per organization
  - _Requirements: 7.1, 7.2, 7.3_

---

- [ ] 10. Implement notes and terms & conditions
  - Add notes input field
  - Implement terms & conditions management
  - Create templates for reusable terms
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [ ] 10.1 Add notes functionality to invoice form
  - Add "Add Notes" button
  - Display text area for notes input
  - Save notes with invoice
  - Display notes on invoice view/print
  - _Requirements: 8.1, 8.5_

- [ ] 10.2 Implement terms & conditions management
  - Create terms & conditions input section
  - Support multiple terms (numbered list)
  - Add/remove individual terms
  - Save terms with invoice
  - _Requirements: 8.2, 8.5_

- [ ] 10.3 Create terms templates
  - Create backend model for terms templates
  - Add CRUD endpoints for templates
  - Create UI to manage templates
  - Auto-populate default terms in new invoices
  - _Requirements: 8.3, 8.4_

- [ ] 10.4 Write unit tests for notes and terms
  - Test notes saving and retrieval
  - Test terms management
  - Test template CRUD operations
  - _Requirements: 8.1, 8.2, 8.3_

---

- [ ] 11. Implement draft and final invoice management
  - Add draft save functionality
  - Implement finalize invoice action
  - Restrict editing of final invoices
  - _Requirements: 15.1, 15.2, 15.3, 15.4, 15.5_

- [ ] 11.1 Implement draft save
  - Save invoice with status "draft"
  - Skip e-invoice generation for drafts
  - Allow editing of draft invoices
  - _Requirements: 15.1, 15.2_

- [ ] 11.2 Implement finalize invoice
  - Add "Finalize" button for draft invoices
  - Trigger e-invoice generation on finalize
  - Change status to "final" on success
  - _Requirements: 15.3_

- [ ] 11.3 Implement edit restrictions
  - Check invoice status before allowing edit
  - Display read-only view for final invoices
  - Show message when edit is attempted on final invoice
  - _Requirements: 15.4, 15.5_

- [ ] 11.4 Write property tests for invoice status
  - **Property 10: Draft invoices are editable**
  - **Property 11: Final invoices are immutable**
  - **Validates: Requirements 15.2, 15.4, 15.5**

---

- [ ] 12. Implement invoice viewing and downloading
  - Create invoice view/print screen
  - Generate PDF with QR code
  - Implement download functionality
  - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5_

- [ ] 12.1 Create InvoiceViewScreen
  - Display complete invoice details
  - Show QR code if e-invoice generated
  - Display IRN prominently
  - Add print and download buttons
  - _Requirements: 14.1, 14.4_

- [ ] 12.2 Implement PDF generation
  - Create PDF template with invoice layout
  - Include QR code in PDF
  - Include IRN and acknowledgement details
  - Format according to GST requirements
  - _Requirements: 14.2, 14.5_

- [ ] 12.3 Implement download functionality
  - Generate PDF on download click
  - Save PDF with invoice number as filename
  - Provide option to email PDF
  - _Requirements: 14.2, 14.3_

- [ ] 12.4 Write unit tests for PDF generation
  - Test PDF creation
  - Test QR code inclusion
  - Test invoice formatting
  - _Requirements: 14.2, 14.5_

---

- [ ] 13. Implement Save & New functionality
  - Add "Save & New" button
  - Clear form after save
  - Auto-increment invoice number
  - _Requirements: 10.4, 10.5_

- [ ] 13.1 Implement Save & New action
  - Save current invoice
  - Clear all form fields
  - Load next invoice number
  - Keep selected organization
  - Reset to draft status
  - _Requirements: 10.4, 10.5_

- [ ] 13.2 Write unit tests for Save & New
  - Test invoice save
  - Test form reset
  - Test invoice number increment
  - _Requirements: 10.4, 10.5_

---

- [ ] 14. Final integration and testing
  - Integrate all components
  - Perform end-to-end testing
  - Fix any integration issues
  - _Requirements: All_

- [ ] 14.1 Integration testing
  - Test complete invoice creation flow
  - Test e-invoice generation flow
  - Test way bill generation flow
  - Test GSTR1 reconciliation flow
  - Test payment recording flow

- [ ] 14.2 User acceptance testing
  - Create test invoices with real data
  - Verify calculations are accurate
  - Test GST API integration (sandbox)
  - Verify QR codes are valid
  - Test PDF generation and download

- [ ] 14.3 Performance testing
  - Test with large number of items
  - Test with multiple concurrent users
  - Measure API response times
  - Optimize slow queries

- [ ] 14.4 Bug fixes and refinements
  - Fix any issues found during testing
  - Refine UI/UX based on feedback
  - Optimize performance bottlenecks

---

- [ ] 15. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.
