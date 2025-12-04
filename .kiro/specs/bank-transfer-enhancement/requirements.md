# Requirements Document

## Introduction

This document specifies the requirements for enhancing the bank transfer functionality in the Cash & Bank module. The enhancement allows users to transfer money not only between their own accounts but also to external bank accounts by manually entering recipient bank details.

## Glossary

- **System**: The Flutter-based SaaS billing platform with Cash & Bank management
- **User**: A customer who manages bank accounts and performs transactions
- **Internal Transfer**: Money transfer between user's own bank accounts within the system
- **External Transfer**: Money transfer to a bank account outside the system by manually entering details
- **From Account**: The source bank account from which money is being transferred
- **To Account**: The destination bank account receiving the transferred money
- **Manual Entry Mode**: UI mode where user manually enters external bank account details
- **Dropdown Mode**: UI mode where user selects from existing accounts in the system
- **Transfer Dialog**: The modal interface for initiating money transfers

## Requirements

### Requirement 1

**User Story:** As a user, I want to choose between selecting an existing account or manually entering bank details when transferring money, so that I can transfer to both internal and external accounts.

#### Acceptance Criteria

1. WHEN a user opens the transfer dialog, THEN the System SHALL display a toggle or option to switch between dropdown selection and manual entry modes
2. WHEN a user selects dropdown mode, THEN the System SHALL display a dropdown list of all user's existing bank accounts
3. WHEN a user selects manual entry mode, THEN the System SHALL display input fields for external bank account details
4. WHEN a user switches between modes, THEN the System SHALL clear any previously entered data in the "To Account" section
5. WHEN the transfer dialog loads, THEN the System SHALL default to dropdown mode for selecting existing accounts

### Requirement 2

**User Story:** As a user, I want to manually enter external bank account details, so that I can transfer money to accounts not registered in my system.

#### Acceptance Criteria

1. WHEN a user enables manual entry mode, THEN the System SHALL display input fields for account holder name, bank account number, bank name, and IFSC code
2. WHEN a user enters bank account details, THEN the System SHALL validate that all required fields are filled before allowing transfer
3. WHEN a user enters an IFSC code, THEN the System SHALL validate the format matches standard IFSC code pattern
4. WHEN a user enters a bank account number, THEN the System SHALL validate it contains only numeric characters
5. WHEN a user submits manual bank details, THEN the System SHALL store these details with the transaction for record-keeping

### Requirement 3

**User Story:** As a user, I want the system to validate my transfer details differently based on whether I'm transferring internally or externally, so that appropriate checks are performed.

#### Acceptance Criteria

1. WHEN a user performs an internal transfer, THEN the System SHALL verify the from and to accounts are different
2. WHEN a user performs an external transfer, THEN the System SHALL skip the same-account validation check
3. WHEN a user performs any transfer, THEN the System SHALL verify the from account has sufficient balance
4. WHEN a user performs an internal transfer, THEN the System SHALL update both account balances in the database
5. WHEN a user performs an external transfer, THEN the System SHALL only deduct from the from account balance

### Requirement 4

**User Story:** As a user, I want clear visual indication of which input mode I'm using, so that I understand whether I'm transferring internally or externally.

#### Acceptance Criteria

1. WHEN a user is in dropdown mode, THEN the System SHALL display a label or icon indicating "Transfer to My Accounts"
2. WHEN a user is in manual entry mode, THEN the System SHALL display a label or icon indicating "Transfer to External Account"
3. WHEN a user switches modes, THEN the System SHALL provide immediate visual feedback of the mode change
4. WHEN displaying the mode toggle, THEN the System SHALL use clear, unambiguous labels
5. WHEN a user hovers over the mode toggle, THEN the System SHALL display a tooltip explaining the difference

### Requirement 5

**User Story:** As a user, I want my external transfer details to be recorded, so that I have a complete transaction history.

#### Acceptance Criteria

1. WHEN a user completes an external transfer, THEN the System SHALL store the recipient bank details with the transaction record
2. WHEN a user views transaction history, THEN the System SHALL display external transfer details including recipient name and bank
3. WHEN a user completes a transfer, THEN the System SHALL record the transaction type as either "internal" or "external"
4. WHEN storing external account details, THEN the System SHALL mask sensitive information like full account numbers in display views
5. WHEN a transaction is recorded, THEN the System SHALL include timestamp, amount, description, and transfer type

### Requirement 6

**User Story:** As a developer, I want the backend API to support external transfer details, so that the system can properly record and retrieve this information.

#### Acceptance Criteria

1. WHEN the backend receives a transfer request with manual account details, THEN the System SHALL accept and store recipient bank information
2. WHEN the backend processes an external transfer, THEN the System SHALL validate all required external account fields are present
3. WHEN the backend stores a transaction, THEN the System SHALL include fields for recipient account holder name, account number, bank name, and IFSC code
4. WHEN the backend returns transaction history, THEN the System SHALL include external account details when applicable
5. WHEN the backend validates IFSC codes, THEN the System SHALL verify the format is 11 characters with correct pattern

### Requirement 7

**User Story:** As a user, I want helpful error messages when my transfer fails, so that I can understand and correct the issue.

#### Acceptance Criteria

1. WHEN a transfer fails due to insufficient balance, THEN the System SHALL display a message indicating the available balance
2. WHEN a transfer fails due to invalid IFSC code, THEN the System SHALL display a message explaining the correct format
3. WHEN a transfer fails due to missing required fields, THEN the System SHALL highlight the specific fields that need attention
4. WHEN a transfer fails due to network error, THEN the System SHALL display a user-friendly error message with retry option
5. WHEN any validation fails, THEN the System SHALL prevent form submission and keep user data intact for correction
