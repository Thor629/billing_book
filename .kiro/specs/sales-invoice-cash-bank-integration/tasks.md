# Implementation Plan

- [x] 1. Implement transaction fetching in BankAccountService



  - Add `getTransactions()` method to fetch transactions from API
  - Handle query parameters for filtering (account_id, start_date, end_date, organization_id)
  - Parse API response and return list of BankTransaction objects
  - Handle error cases and throw appropriate exceptions
  - _Requirements: 2.1, 3.1_






- [ ] 1.1 Write property test for transaction fetching
  - **Property 6: Transaction list completeness**
  - **Validates: Requirements 2.1**

- [ ] 2. Enhance CashBankScreen to fetch and display transactions
  - Add state variables for transactions list and loading state
  - Implement `_loadTransactions()` method to fetch transactions on screen load


  - Calculate date ranges based on selected period filter
  - Update UI to show loading indicator while fetching
  - Handle errors and display error messages
  - _Requirements: 2.1, 3.1_

- [ ] 2.1 Write property test for transaction loading
  - **Property 6: Transaction list completeness**
  - **Validates: Requirements 2.1**

- [ ] 3. Implement transaction list UI
  - Replace "No Transactions" placeholder with actual transaction list
  - Create transaction list item widget with icon, description, date, and amount
  - Format transaction dates using DateFormat
  - Format amounts with currency symbol and proper decimal places
  - Add appropriate icons and colors based on transaction type (add=green, reduce=red)
  - Display transaction description with invoice number when applicable
  - _Requirements: 2.2, 2.3, 2.4_

- [ ] 3.1 Write property test for transaction display
  - **Property 7: Transaction display fields**
  - **Validates: Requirements 2.2**

- [ ] 3.2 Write property test for transaction ordering
  - **Property 8: Transaction ordering**
  - **Validates: Requirements 2.3**

- [ ] 4. Implement time period filtering
  - Update `_loadTransactions()` to calculate start_date based on selected period
  - Implement date calculation for "Last 30 Days" (30 days ago to today)
  - Implement date calculation for "Last 90 Days" (90 days ago to today)
  - Implement date calculation for "This Year" (Jan 1 to today)
  - Reload transactions when period filter changes
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [ ] 4.1 Write property test for time period filtering
  - **Property 10: Time period filtering**
  - **Validates: Requirements 3.1**

- [ ] 5. Verify backend transaction creation from sales invoices
  - Review SalesInvoiceController::store() to confirm transaction creation logic
  - Verify Cash account is created/found when payment_mode is "Cash"
  - Verify transaction description includes invoice number
  - Verify account balance is updated correctly
  - Test creating invoices with different payment methods
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [ ] 5.1 Write property test for transaction creation from invoice
  - **Property 1: Transaction creation from invoice**
  - **Validates: Requirements 1.1**

- [ ] 5.2 Write property test for Cash account handling
  - **Property 2: Cash account handling**
  - **Validates: Requirements 1.2**

- [ ] 5.3 Write property test for bank account association
  - **Property 3: Bank account association**
  - **Validates: Requirements 1.3**

- [ ] 5.4 Write property test for invoice number in description
  - **Property 4: Invoice number in description**
  - **Validates: Requirements 1.4**

- [ ] 5.5 Write property test for balance update
  - **Property 5: Balance update on transaction**
  - **Validates: Requirements 1.5, 4.1**

- [ ] 6. Add empty state handling
  - Check if transactions list is empty after loading
  - Display helpful message when no transactions exist
  - Show icon and descriptive text for empty state
  - _Requirements: 2.5_

- [ ] 7. Implement account balance display updates
  - Ensure account balances refresh after transactions are loaded
  - Verify displayed balances match database values
  - Test balance updates after creating new transactions
  - _Requirements: 4.3_

- [ ] 7.1 Write property test for balance display accuracy
  - **Property 12: Balance display accuracy**
  - **Validates: Requirements 4.3**

- [ ] 8. Add transaction type indicators
  - Add icons for different transaction types (add, reduce, transfer_in, transfer_out)
  - Use green color for incoming transactions (add, transfer_in)
  - Use red color for outgoing transactions (reduce, transfer_out)
  - Add "+" prefix for positive amounts and "-" for negative amounts
  - _Requirements: 2.2_

- [ ] 9. Test end-to-end integration
  - Create a sales invoice with Cash payment
  - Navigate to Cash & Bank section
  - Verify transaction appears in the list
  - Verify transaction description contains invoice number
  - Verify Cash account balance is updated
  - Test with different payment methods (Card, UPI, Bank Transfer)
  - Test with different bank accounts selected
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 2.1, 2.2, 2.3, 2.4_

- [ ] 9.1 Write integration test for invoice to transaction flow
  - **Property 1: Transaction creation from invoice**
  - **Validates: Requirements 1.1**

- [ ] 10. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.
