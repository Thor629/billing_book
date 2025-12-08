# Design Document

## Overview

This feature integrates sales invoice payments with the Cash & Bank section, ensuring that when a user creates a sales invoice with payment, the transaction automatically appears in the Cash & Bank transaction list. The backend already creates bank transactions when invoices are saved with payment, but the frontend Cash & Bank screen currently doesn't fetch or display these transactions. This design focuses on completing the integration by implementing transaction fetching, display, and filtering in the frontend.

## Architecture

The system follows a three-tier architecture:

1. **Backend (Laravel/PHP)**: Already handles transaction creation when invoices are saved
2. **API Layer**: Existing endpoints for fetching transactions need to be utilized
3. **Frontend (Flutter)**: Needs to fetch and display transactions in the Cash & Bank screen

### Data Flow

```
Sales Invoice Creation → Backend Creates Transaction → Database
                                                          ↓
Cash & Bank Screen → API Request → Backend Fetches Transactions → Display
```

## Components and Interfaces

### Backend Components (Existing)

#### BankTransactionController
- **Purpose**: Handles CRUD operations for bank transactions
- **Key Methods**:
  - `index(Request $request)`: Fetches transactions with optional filters
  - `store(Request $request)`: Creates new transactions
  - `transfer(Request $request)`: Handles money transfers

#### SalesInvoiceController
- **Purpose**: Handles sales invoice operations
- **Key Method** (already implemented):
  - `store(Request $request)`: Creates invoice and bank transaction when payment is received

### Frontend Components (To Be Enhanced)

#### BankAccountService
- **Purpose**: Service layer for bank account and transaction operations
- **New Method Needed**:
  - `getTransactions(String token, int? organizationId, {String? startDate, String? endDate, int? accountId})`: Fetches transactions from API

#### CashBankScreen
- **Purpose**: Displays cash and bank accounts with their transactions
- **Enhancements Needed**:
  - Fetch transactions on screen load
  - Display transactions in a list
  - Implement time period filtering
  - Handle empty states

## Data Models

### BankTransaction (Existing)
```dart
class BankTransaction {
  final int? id;
  final int userId;
  final int? organizationId;
  final int accountId;
  final String transactionType; // 'add', 'reduce', 'transfer_out', 'transfer_in'
  final double amount;
  final String transactionDate;
  final String? description;
  final int? relatedAccountId;
  final int? relatedTransactionId;
  final bool isExternalTransfer;
  final String? externalAccountHolder;
  final String? externalAccountNumber;
  final String? externalBankName;
  final String? externalIfscCode;
  final String? createdAt;
  final String? updatedAt;
}
```

### Transaction Display Model
```dart
class TransactionDisplay {
  final BankTransaction transaction;
  final String accountName;
  final String formattedDate;
  final String formattedAmount;
  final Color amountColor;
  final IconData icon;
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Transaction creation from invoice
*For any* sales invoice with amount_received > 0, creating the invoice should result in a bank transaction being created with the same amount and correct account_id
**Validates: Requirements 1.1**

### Property 2: Cash account handling
*For any* sales invoice with payment_mode = "Cash", the system should create or use a Cash account and record the transaction against it
**Validates: Requirements 1.2**

### Property 3: Bank account association
*For any* sales invoice with a selected bank_account_id, the created transaction should have the same account_id
**Validates: Requirements 1.3**

### Property 4: Invoice number in description
*For any* bank transaction created from a sales invoice, the transaction description should contain the invoice number
**Validates: Requirements 1.4**

### Property 5: Balance update on transaction
*For any* bank transaction of type 'add', the account balance after creation should equal the balance before plus the transaction amount
**Validates: Requirements 1.5, 4.1**

### Property 6: Transaction list completeness
*For any* set of transactions in the database for an organization, fetching transactions should return all of them
**Validates: Requirements 2.1**

### Property 7: Transaction display fields
*For any* transaction displayed in the UI, the rendered output should contain the transaction date, description, amount, and transaction type
**Validates: Requirements 2.2**

### Property 8: Transaction ordering
*For any* list of transactions, they should be ordered by transaction_date in descending order (newest first)
**Validates: Requirements 2.3**

### Property 9: Invoice transaction identification
*For any* transaction created from a sales invoice, the description should contain text indicating it's from an invoice (e.g., "Sales Invoice")
**Validates: Requirements 2.4**

### Property 10: Time period filtering
*For any* time period filter and set of transactions, only transactions within that period should be displayed
**Validates: Requirements 3.1**

### Property 11: Balance persistence
*For any* account balance update, reading the balance from the database should return the updated value
**Validates: Requirements 4.2**

### Property 12: Balance display accuracy
*For any* account, the displayed balance in the Cash & Bank screen should match the current_balance in the database
**Validates: Requirements 4.3**

### Property 13: Transaction rollback on failure
*For any* transaction that fails to save, the account balance should remain unchanged from its pre-transaction value
**Validates: Requirements 4.5**

## Error Handling

### Backend Error Scenarios
1. **Insufficient Balance**: When reducing money or transferring, check balance first
2. **Invalid Account**: Verify account exists and belongs to user
3. **Database Transaction Failure**: Use DB transactions to ensure atomicity
4. **Validation Errors**: Return 422 with detailed error messages

### Frontend Error Scenarios
1. **Network Failure**: Display error message and retry option
2. **Authentication Failure**: Redirect to login
3. **Empty Data**: Show helpful empty state message
4. **Loading State**: Display loading indicator during API calls

### Error Response Format
```json
{
  "error": "Error message",
  "details": "Additional context"
}
```

## Testing Strategy

### Unit Tests
- Test transaction creation logic in SalesInvoiceController
- Test transaction fetching with various filters
- Test balance calculation logic
- Test date filtering logic
- Test transaction display formatting

### Property-Based Tests
We will use the `test` package with custom generators for property-based testing in Dart/Flutter.

**Property Test Examples**:
1. Generate random sales invoices with payments → verify transactions created
2. Generate random transactions → verify they appear in the list
3. Generate random date ranges → verify filtering works correctly
4. Generate random balance updates → verify persistence

### Integration Tests
- Test complete flow: Create invoice → Verify transaction appears in Cash & Bank
- Test filtering: Apply filter → Verify correct transactions shown
- Test balance updates: Create transaction → Verify balance updated

### Manual Testing Checklist
- Create sales invoice with Cash payment → Check Cash & Bank section
- Create sales invoice with bank account → Check transaction appears
- Apply different time filters → Verify correct transactions shown
- Create multiple transactions → Verify all appear in correct order
- Test with no transactions → Verify empty state displays

## Implementation Notes

### Backend (Already Implemented)
The backend already handles transaction creation in `SalesInvoiceController::store()`:
- Creates bank transaction when amount_received > 0
- Handles Cash account creation/lookup
- Updates account balance
- Includes invoice number in description

### Frontend Implementation Priorities
1. **High Priority**:
   - Implement `getTransactions()` in BankAccountService
   - Fetch and display transactions in CashBankScreen
   - Implement basic transaction list UI

2. **Medium Priority**:
   - Implement time period filtering
   - Add transaction type icons and colors
   - Format dates and amounts properly

3. **Low Priority**:
   - Add transaction search
   - Add export functionality
   - Add transaction details view

### API Endpoint Usage
```
GET /api/bank-transactions
Query Parameters:
  - account_id (optional): Filter by account
  - start_date (optional): Filter by start date
  - end_date (optional): Filter by end date
  - organization_id (optional): Filter by organization
```

### UI Components

#### Transaction List Item
```dart
ListTile(
  leading: Icon(transactionIcon, color: transactionColor),
  title: Text(transaction.description),
  subtitle: Text(formattedDate),
  trailing: Text(
    formattedAmount,
    style: TextStyle(
      color: amountColor,
      fontWeight: FontWeight.bold,
    ),
  ),
)
```

#### Time Period Filter
```dart
DropdownButton<String>(
  value: selectedPeriod,
  items: ['Last 30 Days', 'Last 90 Days', 'This Year'],
  onChanged: (value) => _applyFilter(value),
)
```

## Performance Considerations

1. **Pagination**: Implement pagination for large transaction lists
2. **Caching**: Cache transaction data to reduce API calls
3. **Lazy Loading**: Load transactions only when Cash & Bank screen is opened
4. **Debouncing**: Debounce filter changes to avoid excessive API calls

## Security Considerations

1. **Authorization**: Verify user has access to organization's transactions
2. **Data Filtering**: Backend filters transactions by user_id and organization_id
3. **Sensitive Data**: Mask external account numbers in display
4. **API Authentication**: All requests require valid authentication token

## Future Enhancements

1. **Transaction Editing**: Allow editing transaction descriptions
2. **Transaction Deletion**: Allow deleting transactions (with balance adjustment)
3. **Transaction Categories**: Add categories for better organization
4. **Reports**: Generate transaction reports and summaries
5. **Reconciliation**: Add bank reconciliation features
6. **Attachments**: Allow attaching receipts/documents to transactions
