# Requirements Document

## Introduction

This feature enhances the integration between Sales Invoices and the Cash & Bank section. When a user creates a sales invoice and selects a payment method (Cash, Card, UPI, or Bank Transfer) with an amount received, that payment transaction should automatically appear in the Cash & Bank section, providing a complete view of all cash and bank transactions across the application.

## Glossary

- **Sales Invoice**: A document issued to a customer detailing goods or services sold and the amount owed
- **Cash & Bank Section**: The application module that displays all cash and bank account balances and transactions
- **Bank Transaction**: A record of money added to or removed from a cash or bank account
- **Payment Method**: The mode of payment selected for an invoice (Cash, Card, UPI, Bank Transfer)
- **Amount Received**: The payment amount collected at the time of invoice creation
- **Bank Account**: A cash or bank account entity that tracks balances and transactions
- **Transaction List**: The display of all transactions for cash and bank accounts in chronological order

## Requirements

### Requirement 1

**User Story:** As a user, I want to see sales invoice payments in the Cash & Bank section, so that I can track all my cash and bank transactions in one place.

#### Acceptance Criteria

1. WHEN a user creates a sales invoice with an amount received greater than zero THEN the system SHALL create a corresponding bank transaction record
2. WHEN a user selects "Cash" as the payment method THEN the system SHALL create or use a default Cash account and record the transaction
3. WHEN a user selects a specific bank account THEN the system SHALL record the transaction against that bank account
4. WHEN a bank transaction is created from a sales invoice THEN the system SHALL include the invoice number in the transaction description
5. WHEN a bank transaction is created THEN the system SHALL update the corresponding account balance immediately

### Requirement 2

**User Story:** As a user, I want to view all transactions in the Cash & Bank section, so that I can see a complete history of my cash and bank activities.

#### Acceptance Criteria

1. WHEN a user opens the Cash & Bank section THEN the system SHALL fetch and display all transactions for all accounts
2. WHEN displaying transactions THEN the system SHALL show the transaction date, description, amount, and transaction type
3. WHEN displaying transactions THEN the system SHALL order them by date in descending order (newest first)
4. WHEN a transaction originates from a sales invoice THEN the system SHALL clearly indicate this in the transaction description
5. WHEN the transaction list is empty THEN the system SHALL display a helpful message indicating no transactions exist

### Requirement 3

**User Story:** As a user, I want to filter transactions by time period, so that I can focus on relevant transaction history.

#### Acceptance Criteria

1. WHEN a user selects a time period filter THEN the system SHALL display only transactions within that period
2. WHEN the "Last 30 Days" filter is selected THEN the system SHALL show transactions from the past 30 days
3. WHEN the "Last 90 Days" filter is selected THEN the system SHALL show transactions from the past 90 days
4. WHEN the "This Year" filter is selected THEN the system SHALL show transactions from the current calendar year
5. WHEN a filter is applied THEN the system SHALL maintain the filter selection until the user changes it

### Requirement 4

**User Story:** As a user, I want the account balances to update automatically when transactions are created, so that I always see accurate financial information.

#### Acceptance Criteria

1. WHEN a sales invoice payment is recorded THEN the system SHALL increment the corresponding account balance by the payment amount
2. WHEN an account balance is updated THEN the system SHALL persist the new balance to the database
3. WHEN the Cash & Bank section is loaded THEN the system SHALL display the current balance for each account
4. WHEN multiple transactions are created THEN the system SHALL update balances atomically to prevent race conditions
5. WHEN a transaction fails to save THEN the system SHALL not update the account balance
