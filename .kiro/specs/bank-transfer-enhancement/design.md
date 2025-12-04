# Design Document: Bank Transfer Enhancement

## Overview

This design enhances the existing bank transfer functionality in the Cash & Bank module to support both internal transfers (between user's own accounts) and external transfers (to manually entered bank accounts). The enhancement adds a mode toggle in the Transfer Money dialog that allows users to switch between selecting from existing accounts or manually entering external bank details.

The design maintains backward compatibility with existing transfer functionality while extending the data model to capture external recipient information.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Frontend                          │
│  ┌────────────────────────────────────────────────────────┐ │
│  │         Transfer Money Dialog (Enhanced)               │ │
│  │  ┌──────────────┐  ┌──────────────────────────────┐  │ │
│  │  │ Mode Toggle  │  │  From Account (Dropdown)     │  │ │
│  │  └──────────────┘  └──────────────────────────────┘  │ │
│  │                                                        │ │
│  │  ┌─────────────────────────────────────────────────┐ │ │
│  │  │ To Account Section (Conditional Rendering)      │ │ │
│  │  │  • Dropdown Mode: Select existing account       │ │ │
│  │  │  • Manual Mode: Input external bank details     │ │ │
│  │  └─────────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ HTTP/JSON
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    Laravel Backend API                       │
│  ┌────────────────────────────────────────────────────────┐ │
│  │      BankTransactionController (Enhanced)              │ │
│  │  • transfer() - handles both internal & external       │ │
│  │  • Validates transfer type and required fields         │ │
│  │  • Creates transaction records with recipient details  │ │
│  └────────────────────────────────────────────────────────┘ │
│                            │                                 │
│                            ▼                                 │
│  ┌────────────────────────────────────────────────────────┐ │
│  │         Database (bank_transactions table)             │ │
│  │  • Existing fields for internal transfers              │ │
│  │  • New fields for external recipient details           │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### Component Interaction Flow

1. **User Interaction**: User opens Transfer Money dialog
2. **Mode Selection**: User toggles between "My Accounts" and "External Account"
3. **Data Entry**: User fills in transfer details based on selected mode
4. **Validation**: Frontend validates required fields based on mode
5. **API Request**: Frontend sends transfer request with mode indicator
6. **Backend Processing**: Backend validates and processes based on transfer type
7. **Database Update**: Transaction recorded with appropriate recipient details
8. **Response**: Success/error message displayed to user

## Components and Interfaces

### Frontend Components

#### 1. Enhanced Transfer Money Dialog (`_TransferMoneyDialog`)

**State Variables:**
- `_isManualEntry: bool` - Toggle between dropdown and manual entry modes
- `_fromAccount: BankAccount?` - Selected source account
- `_toAccount: BankAccount?` - Selected destination account (dropdown mode)
- `_manualAccountHolderName: String` - External account holder name
- `_manualAccountNumber: String` - External account number
- `_manualBankName: String` - External bank name
- `_manualIfscCode: String` - External IFSC code
- `_amount: double` - Transfer amount
- `_date: String` - Transfer date
- `_description: String?` - Optional description

**Methods:**
- `_toggleEntryMode()` - Switches between dropdown and manual entry, clears "To Account" data
- `_validateManualEntry()` - Validates external bank account fields
- `_validateIfscCode(String)` - Validates IFSC code format (11 chars, alphanumeric)
- `_transferMoney()` - Submits transfer request to backend

**UI Structure:**
```
Transfer Money Dialog
├── From Account (Dropdown) - Always visible
├── Mode Toggle (Radio/Switch)
│   ├── "My Accounts" (Dropdown mode)
│   └── "External Account" (Manual mode)
├── To Account Section (Conditional)
│   ├── IF Dropdown Mode:
│   │   └── Account Dropdown
│   └── IF Manual Mode:
│       ├── Account Holder Name (TextField)
│       ├── Account Number (TextField)
│       ├── Bank Name (TextField)
│       └── IFSC Code (TextField)
├── Amount (TextField)
├── Date (DatePicker)
├── Description (TextField - Optional)
└── Actions (Cancel / Transfer buttons)
```

#### 2. Bank Account Service (`BankAccountService`)

**Enhanced Method:**
```dart
Future<void> transferMoney({
  required String token,
  required int fromAccountId,
  int? toAccountId,  // Null for external transfers
  required double amount,
  required String date,
  String? description,
  // New parameters for external transfers
  String? externalAccountHolder,
  String? externalAccountNumber,
  String? externalBankName,
  String? externalIfscCode,
  bool isExternal = false,
})
```

### Backend Components

#### 1. Database Migration

**New Migration: `add_external_transfer_fields_to_bank_transactions`**

Adds the following fields to `bank_transactions` table:
- `is_external_transfer: boolean` (default: false)
- `external_account_holder: string` (nullable)
- `external_account_number: string` (nullable)
- `external_bank_name: string` (nullable)
- `external_ifsc_code: string` (nullable)

#### 2. BankTransaction Model

**Enhanced Fillable Fields:**
```php
protected $fillable = [
    // Existing fields
    'user_id',
    'organization_id',
    'account_id',
    'transaction_type',
    'amount',
    'transaction_date',
    'description',
    'related_account_id',
    'related_transaction_id',
    // New fields
    'is_external_transfer',
    'external_account_holder',
    'external_account_number',
    'external_bank_name',
    'external_ifsc_code',
];

protected $casts = [
    'amount' => 'decimal:2',
    'transaction_date' => 'date',
    'is_external_transfer' => 'boolean',
];
```

#### 3. BankTransactionController

**Enhanced `transfer()` Method:**

```php
public function transfer(Request $request)
{
    $isExternal = $request->boolean('is_external_transfer', false);
    
    $rules = [
        'from_account_id' => 'required|exists:bank_accounts,id',
        'amount' => 'required|numeric|min:0.01',
        'transaction_date' => 'required|date',
        'description' => 'nullable|string',
        'is_external_transfer' => 'boolean',
    ];
    
    if ($isExternal) {
        $rules['external_account_holder'] = 'required|string|max:255';
        $rules['external_account_number'] = 'required|string|max:50';
        $rules['external_bank_name'] = 'required|string|max:255';
        $rules['external_ifsc_code'] = 'required|string|size:11|regex:/^[A-Z]{4}0[A-Z0-9]{6}$/';
    } else {
        $rules['to_account_id'] = 'required|exists:bank_accounts,id|different:from_account_id';
    }
    
    // Validation and processing logic
    // ...
}
```

## Data Models

### Enhanced BankTransaction Model

```dart
class BankTransaction {
  final int? id;
  final int userId;
  final int? organizationId;
  final int accountId;
  final String transactionType;
  final double amount;
  final String transactionDate;
  final String? description;
  final int? relatedAccountId;
  final int? relatedTransactionId;
  
  // New fields for external transfers
  final bool isExternalTransfer;
  final String? externalAccountHolder;
  final String? externalAccountNumber;
  final String? externalBankName;
  final String? externalIfscCode;
  
  final String? createdAt;
  final String? updatedAt;
  
  // Constructor and methods...
}
```

### Database Schema Changes

**Table: bank_transactions**

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| is_external_transfer | BOOLEAN | DEFAULT false | Indicates if transfer is to external account |
| external_account_holder | VARCHAR(255) | NULLABLE | Recipient's name for external transfers |
| external_account_number | VARCHAR(50) | NULLABLE | Recipient's account number |
| external_bank_name | VARCHAR(255) | NULLABLE | Recipient's bank name |
| external_ifsc_code | VARCHAR(11) | NULLABLE | Recipient's IFSC code |


## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Mode switching clears destination data
*For any* transfer dialog state with data entered in the "To Account" section, switching between dropdown and manual entry modes should clear all previously entered destination account data.
**Validates: Requirements 1.4**

### Property 2: Manual mode displays required input fields
*For any* transfer dialog in manual entry mode, the UI should render input fields for account holder name, bank account number, bank name, and IFSC code.
**Validates: Requirements 1.3, 2.1**

### Property 3: Required field validation
*For any* external transfer submission with one or more required fields empty, the system should reject the submission and display validation errors.
**Validates: Requirements 2.2, 6.2**

### Property 4: IFSC code format validation
*For any* IFSC code input, the system should accept only strings that match the pattern: 4 uppercase letters, followed by '0', followed by 6 alphanumeric characters (total 11 characters).
**Validates: Requirements 2.3, 6.5**

### Property 5: Account number numeric validation
*For any* bank account number input, the system should accept only strings containing numeric characters.
**Validates: Requirements 2.4**

### Property 6: External transfer data persistence
*For any* completed external transfer, the stored transaction record should contain all provided external account details (account holder, account number, bank name, IFSC code).
**Validates: Requirements 2.5, 5.1, 6.1, 6.3**

### Property 7: Internal transfer same-account rejection
*For any* internal transfer attempt where the from account and to account are the same, the system should reject the transfer with an appropriate error message.
**Validates: Requirements 3.1**

### Property 8: Sufficient balance validation
*For any* transfer attempt (internal or external), if the transfer amount exceeds the from account's current balance, the system should reject the transfer.
**Validates: Requirements 3.3**

### Property 9: Internal transfer balance updates
*For any* successful internal transfer, both the from account balance should decrease by the transfer amount and the to account balance should increase by the same amount.
**Validates: Requirements 3.4**

### Property 10: External transfer balance update
*For any* successful external transfer, only the from account balance should decrease by the transfer amount, with no changes to any other account in the system.
**Validates: Requirements 3.5**

### Property 11: Transaction type recording
*For any* completed transfer, the transaction record should include a clear indicator of whether it was an internal or external transfer.
**Validates: Requirements 5.3**

### Property 12: Account number masking in display
*For any* external transfer displayed in transaction history, the account number should be masked (e.g., showing only last 4 digits) to protect sensitive information.
**Validates: Requirements 5.4**

### Property 13: Transaction record completeness
*For any* recorded transaction, the database record should include timestamp, amount, description (if provided), and transfer type fields.
**Validates: Requirements 5.5**

### Property 14: External details in transaction history
*For any* external transfer in transaction history, the returned data should include recipient name and bank name for display purposes.
**Validates: Requirements 5.2, 6.4**

### Property 15: Validation failure preserves form data
*For any* transfer form submission that fails validation, the form should retain all user-entered data to allow correction without re-entry.
**Validates: Requirements 7.5**

## Error Handling

### Validation Errors

**Frontend Validation:**
- Empty required fields: "This field is required"
- Invalid IFSC code: "IFSC code must be 11 characters (e.g., SBIN0001234)"
- Non-numeric account number: "Account number must contain only digits"
- Insufficient balance: "Insufficient balance. Available: ₹{balance}"
- Same account transfer: "Cannot transfer to the same account"

**Backend Validation:**
- Missing external account fields: HTTP 422 with field-specific errors
- Invalid IFSC format: "Invalid IFSC code format"
- Account not found: HTTP 404 "Account not found"
- Insufficient balance: HTTP 400 "Insufficient balance"

### Network Errors

- Connection timeout: "Connection timeout. Please check your internet and try again."
- Server error: "Something went wrong. Please try again later."
- Authentication error: "Session expired. Please log in again."

### Error Recovery

1. **Validation Errors**: Form remains open with errors highlighted, data preserved
2. **Network Errors**: Show error message with "Retry" button
3. **Server Errors**: Log error details, show user-friendly message
4. **Balance Errors**: Display current balance and suggest reducing amount

## Testing Strategy

### Unit Testing

**Frontend Unit Tests:**
1. Mode toggle functionality
   - Test switching from dropdown to manual mode clears dropdown selection
   - Test switching from manual to dropdown mode clears manual input fields
   - Test default mode is dropdown on dialog open

2. Validation logic
   - Test IFSC code validation with valid and invalid formats
   - Test account number validation accepts only numeric input
   - Test required field validation for manual entry mode
   - Test balance validation logic

3. Form state management
   - Test form data preservation on validation failure
   - Test form reset after successful transfer

**Backend Unit Tests:**
1. Transfer controller validation
   - Test internal transfer validation rules
   - Test external transfer validation rules
   - Test IFSC code regex validation

2. Transaction creation
   - Test internal transfer creates two linked transactions
   - Test external transfer creates single transaction with external details
   - Test balance updates for both transfer types

3. Data persistence
   - Test external account details are stored correctly
   - Test transaction type indicator is set properly

### Property-Based Testing

The testing framework for Flutter/Dart will be **faker** for data generation and standard Flutter test framework for property testing.

**Property Test Configuration:**
- Minimum iterations per property: 100
- Use faker package for generating random test data
- Each property test must reference its design document property number

**Test Data Generators:**

1. **Valid IFSC Code Generator**
   ```dart
   String generateValidIfsc() {
     // Generate: 4 uppercase letters + '0' + 6 alphanumeric
     final bank = faker.randomGenerator.string(4, min: 4).toUpperCase();
     final branch = faker.randomGenerator.string(6, min: 6).toUpperCase();
     return '${bank}0$branch';
   }
   ```

2. **Invalid IFSC Code Generator**
   ```dart
   String generateInvalidIfsc() {
     // Generate various invalid formats
     final types = [
       () => faker.randomGenerator.string(10), // Wrong length
       () => 'ABCD1234567', // Wrong pattern (no 0 in 5th position)
       () => 'abc0123456', // Lowercase letters
       () => 'ABCD0@#$%^', // Special characters
     ];
     return types[faker.randomGenerator.integer(types.length)]();
   }
   ```

3. **Bank Account Generator**
   ```dart
   BankAccount generateBankAccount({double? balance}) {
     return BankAccount(
       id: faker.randomGenerator.integer(1000),
       accountName: faker.company.name(),
       currentBalance: balance ?? faker.randomGenerator.decimal(scale: 10000),
       accountType: faker.randomGenerator.element(['cash', 'bank']),
       // ... other fields
     );
   }
   ```

4. **Transfer Amount Generator**
   ```dart
   double generateTransferAmount({double? maxAmount}) {
     return faker.randomGenerator.decimal(
       scale: maxAmount ?? 10000,
       min: 0.01,
     );
   }
   ```

### Integration Testing

1. **End-to-End Transfer Flows**
   - Test complete internal transfer flow from UI to database
   - Test complete external transfer flow from UI to database
   - Test mode switching during transfer process

2. **API Integration**
   - Test frontend service calls backend API correctly
   - Test backend returns expected response format
   - Test error responses are handled properly

3. **Database Integration**
   - Test transactions are persisted correctly
   - Test account balances are updated atomically
   - Test external account details are retrievable

### Manual Testing Checklist

- [ ] Verify mode toggle is visible and functional
- [ ] Verify dropdown mode shows all user accounts
- [ ] Verify manual mode shows all required fields
- [ ] Verify IFSC code validation provides helpful error messages
- [ ] Verify successful internal transfer updates both accounts
- [ ] Verify successful external transfer updates only source account
- [ ] Verify transaction history displays external transfer details
- [ ] Verify account numbers are masked in transaction history
- [ ] Verify error messages are clear and actionable
- [ ] Verify form data is preserved on validation errors

## Implementation Notes

### Frontend Implementation

1. **State Management**: Use StatefulWidget with local state for dialog
2. **Form Validation**: Use Form widget with validators
3. **Conditional Rendering**: Use conditional expressions to show/hide fields based on mode
4. **API Integration**: Enhance existing BankAccountService methods

### Backend Implementation

1. **Database Migration**: Create migration to add new fields
2. **Model Updates**: Add new fields to fillable and casts arrays
3. **Controller Logic**: Enhance transfer method with conditional validation
4. **API Response**: Include external details in transaction responses

### Security Considerations

1. **Data Masking**: Mask account numbers in API responses (show only last 4 digits)
2. **Input Sanitization**: Sanitize all user inputs before storage
3. **IFSC Validation**: Strict regex validation to prevent injection
4. **Authorization**: Verify user owns the from account before transfer

### Performance Considerations

1. **Database Indexing**: Ensure indexes on frequently queried fields
2. **Transaction Atomicity**: Use database transactions for balance updates
3. **API Response Size**: Only include necessary fields in responses
4. **Caching**: Consider caching user's account list in frontend

## Future Enhancements

1. **IFSC Code Lookup**: Auto-fill bank name and branch from IFSC code
2. **Beneficiary Management**: Save frequently used external accounts
3. **Transfer Templates**: Save and reuse transfer configurations
4. **Bulk Transfers**: Support multiple transfers in one operation
5. **Transfer Scheduling**: Schedule transfers for future dates
6. **Transfer Limits**: Implement daily/monthly transfer limits
7. **Two-Factor Authentication**: Require 2FA for large transfers
8. **Transfer Receipts**: Generate PDF receipts for transfers
