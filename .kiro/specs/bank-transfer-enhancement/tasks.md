# Implementation Plan: Bank Transfer Enhancement

## Overview
This implementation plan adds the ability for users to transfer money to external bank accounts by manually entering recipient details, in addition to the existing dropdown selection for internal transfers.

---

## Tasks

- [x] 1. Backend: Add database migration for external transfer fields


  - Create migration file to add new columns to bank_transactions table
  - Add columns: is_external_transfer (boolean), external_account_holder (string), external_account_number (string), external_bank_name (string), external_ifsc_code (string)
  - Run migration to update database schema
  - _Requirements: 6.3_



- [ ] 2. Backend: Update BankTransaction model
  - Add new fields to $fillable array
  - Add 'is_external_transfer' to $casts array as boolean


  - Update model to handle external transfer fields
  - _Requirements: 6.1, 6.3_

- [ ] 3. Backend: Enhance transfer API endpoint
  - Update validation rules in BankTransactionController::transfer()
  - Add conditional validation based on is_external_transfer flag
  - For external transfers: validate external_account_holder, external_account_number, external_bank_name, external_ifsc_code
  - Add IFSC code regex validation: /^[A-Z]{4}0[A-Z0-9]{6}$/
  - For internal transfers: keep existing validation (to_account_id required and different from from_account_id)
  - Update transfer logic to handle external transfers (only deduct from source account)
  - Store external account details when is_external_transfer is true
  - _Requirements: 2.3, 3.1, 3.2, 3.5, 6.2, 6.5_

- [ ]* 3.1 Write property test for IFSC validation
  - **Property 4: IFSC code format validation**
  - **Validates: Requirements 2.3, 6.5**



- [ ]* 3.2 Write property test for external transfer balance update
  - **Property 10: External transfer balance update**
  - **Validates: Requirements 3.5**

- [ ] 4. Backend: Update transaction retrieval to include external details
  - Modify index() method to return external account fields
  - Implement account number masking for display (show only last 4 digits)


  - Ensure external details are included in API responses
  - _Requirements: 5.2, 5.4, 6.4_

- [x]* 4.1 Write property test for account number masking


  - **Property 12: Account number masking in display**
  - **Validates: Requirements 5.4**

- [ ] 5. Frontend: Update BankTransaction model
  - Add new fields to BankTransaction class: isExternalTransfer, externalAccountHolder, externalAccountNumber, externalBankName, externalIfscCode


  - Update fromJson() to parse new fields
  - Update toJson() to include new fields
  - _Requirements: 2.5, 5.1_

- [ ] 6. Frontend: Enhance BankAccountService
  - Update transferMoney() method signature to accept external account parameters
  - Add parameters: isExternal, externalAccountHolder, externalAccountNumber, externalBankName, externalIfscCode
  - Modify API request to include external transfer fields when isExternal is true
  - Make toAccountId optional (null for external transfers)

  - _Requirements: 2.5, 6.1_

- [ ] 7. Frontend: Add mode toggle to Transfer Money Dialog
  - Add _isManualEntry boolean state variable (default: false)
  - Create radio buttons or segmented control for "My Accounts" vs "External Account"
  - Add toggle UI above the "To Account" section
  - Implement _toggleEntryMode() method to switch modes
  - _Requirements: 1.1, 1.5_


- [ ]* 7.1 Write unit test for mode toggle default state
  - Test that dialog initializes with dropdown mode (isManualEntry = false)
  - _Requirements: 1.5_

- [ ] 8. Frontend: Implement conditional rendering for To Account section
  - Add conditional rendering based on _isManualEntry flag
  - When false: show dropdown with existing accounts

  - When true: show manual entry fields (account holder, account number, bank name, IFSC)
  - _Requirements: 1.2, 1.3, 2.1_

- [ ]* 8.1 Write property test for manual mode field display
  - **Property 2: Manual mode displays required input fields**
  - **Validates: Requirements 1.3, 2.1**

- [ ] 9. Frontend: Add manual entry input fields
  - Create TextFormField for Account Holder Name (required)

  - Create TextFormField for Account Number (required, numeric only)
  - Create TextFormField for Bank Name (required)
  - Create TextFormField for IFSC Code (required, 11 characters)
  - Add controllers: _manualAccountHolderController, _manualAccountNumberController, _manualBankNameController, _manualIfscController
  - _Requirements: 2.1_

- [ ] 10. Frontend: Implement mode switching data clearing
  - Update _toggleEntryMode() to clear dropdown selection when switching to manual
  - Clear all manual entry controllers when switching to dropdown
  - Reset validation errors on mode switch
  - _Requirements: 1.4_

- [ ]* 10.1 Write property test for mode switching clears data
  - **Property 1: Mode switching clears destination data**
  - **Validates: Requirements 1.4**

- [ ] 11. Frontend: Add validation for manual entry fields
  - Add validator for Account Holder Name (required, not empty)
  - Add validator for Account Number (required, numeric only)

  - Add validator for Bank Name (required, not empty)
  - Add validator for IFSC Code (required, 11 chars, pattern: XXXX0XXXXXX)
  - Implement _validateIfscCode() method with regex
  - _Requirements: 2.2, 2.3, 2.4_

- [ ]* 11.1 Write property test for required field validation
  - **Property 3: Required field validation**
  - **Validates: Requirements 2.2, 6.2**

- [ ]* 11.2 Write property test for IFSC format validation
  - **Property 4: IFSC code format validation**
  - **Validates: Requirements 2.3, 6.5**

- [ ]* 11.3 Write property test for account number validation
  - **Property 5: Account number numeric validation**

  - **Validates: Requirements 2.4**

- [ ] 12. Frontend: Update transfer submission logic
  - Modify _transferMoney() to check _isManualEntry flag
  - For manual entry: validate manual fields and pass external account details to service
  - For dropdown: use existing logic with toAccountId
  - Skip same-account validation for external transfers
  - Maintain balance validation for all transfers
  - _Requirements: 3.1, 3.2, 3.3_

- [x]* 12.1 Write property test for same-account rejection

  - **Property 7: Internal transfer same-account rejection**
  - **Validates: Requirements 3.1**

- [ ]* 12.2 Write property test for balance validation
  - **Property 8: Sufficient balance validation**
  - **Validates: Requirements 3.3**


- [ ] 13. Frontend: Enhance error handling
  - Add specific error messages for insufficient balance (show available balance)
  - Add specific error message for invalid IFSC code format
  - Add field highlighting for validation errors
  - Preserve form data on validation failure
  - Add user-friendly network error messages
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_


- [ ]* 13.1 Write property test for form data preservation on error
  - **Property 15: Validation failure preserves form data**
  - **Validates: Requirements 7.5**

- [ ] 14. Frontend: Add visual indicators for transfer modes
  - Add icon or label for "Transfer to My Accounts" in dropdown mode
  - Add icon or label for "Transfer to External Account" in manual mode
  - Add tooltip on hover explaining the difference between modes
  - Style active mode toggle to provide clear visual feedback
  - _Requirements: 4.1, 4.2, 4.5_

- [ ] 15. Testing: Verify internal transfer functionality still works
  - Test that existing internal transfers work correctly
  - Verify both account balances update properly

  - Verify transaction linking for internal transfers
  - _Requirements: 3.4_

- [ ]* 15.1 Write property test for internal transfer balance updates
  - **Property 9: Internal transfer balance updates**
  - **Validates: Requirements 3.4**

- [ ] 16. Testing: Verify external transfer end-to-end flow
  - Test complete external transfer from UI to database
  - Verify external account details are stored correctly
  - Verify only source account balance is updated
  - Verify transaction type is recorded as external
  - _Requirements: 2.5, 3.5, 5.1, 5.3_



- [ ]* 16.1 Write property test for external transfer data persistence
  - **Property 6: External transfer data persistence**
  - **Validates: Requirements 2.5, 5.1, 6.1, 6.3**

- [ ]* 16.2 Write property test for transaction type recording
  - **Property 11: Transaction type recording**
  - **Validates: Requirements 5.3**

- [ ] 17. Testing: Verify transaction history displays external details
  - Test that transaction history shows external recipient name and bank
  - Verify account numbers are masked in display
  - Verify all transaction fields are present (timestamp, amount, description, type)
  - _Requirements: 5.2, 5.4, 5.5_

- [ ]* 17.1 Write property test for external details in history
  - **Property 14: External details in transaction history**
  - **Validates: Requirements 5.2, 6.4**

- [ ]* 17.2 Write property test for transaction record completeness
  - **Property 13: Transaction record completeness**
  - **Validates: Requirements 5.5**

- [ ] 18. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

---

## Notes

- Tasks marked with `*` are optional testing tasks
- Each property test should run minimum 100 iterations
- Use faker package for generating test data
- All property tests must include comment with property number and validation reference
- Backend changes require database migration before testing
- Frontend changes should maintain backward compatibility with existing transfers
