# Cash/Bank Add/Reduce Money Feature - Complete Implementation

## Overview
The Add/Reduce Money feature allows users to add or reduce money from Cash in Hand or Bank Accounts. The system automatically updates the account balances and displays all transactions in a detailed table format.

## Features Implemented

### 1. Frontend UI (Flutter)
**File**: `flutter_app/lib/screens/user/cash_bank_screen.dart`

#### Add/Reduce Money Dialog
- **Transaction Type Dropdown**: Choose between "Add Money" or "Reduce Money"
- **Account Selection**: Select from Cash in Hand or any Bank Account
- **Amount Field**: Enter the amount to add/reduce
- **Date Picker**: Select transaction date
- **Description**: Optional transaction description

#### Transaction Display Table
New table format with columns:
- **Icon**: Visual indicator (green for add/transfer in, red for reduce/transfer out)
- **Description**: Transaction description or type
- **Account**: Account name (Cash in Hand or Bank Account name)
- **Type Badge**: Color-coded badge showing transaction type:
  - "Add Money" (Green)
  - "Reduce Money" (Red)
  - "Transfer In" (Green)
  - "Transfer Out" (Red)
- **Date**: Transaction date in "dd MMM yyyy" format
- **Amount**: Amount with +/- prefix and color coding

### 2. Backend API (Laravel)
**File**: `backend/app/Http/Controllers/BankTransactionController.php`

#### Store Transaction Endpoint
**Route**: `POST /api/bank-transactions`

**Request Body**:
```json
{
  "account_id": 1,
  "transaction_type": "add",  // or "reduce"
  "amount": 5000.00,
  "transaction_date": "2025-12-06",
  "description": "Initial deposit",
  "organization_id": 1
}
```

**Logic**:
1. Validates the transaction data
2. Checks if account belongs to the authenticated user
3. For "reduce" transactions, verifies sufficient balance
4. Creates the transaction record
5. **Updates account balance**:
   - `add`: Increases `current_balance` by amount
   - `reduce`: Decreases `current_balance` by amount
6. Uses database transaction for data integrity

**Response**:
```json
{
  "id": 1,
  "user_id": 1,
  "organization_id": 1,
  "account_id": 1,
  "transaction_type": "add",
  "amount": 5000.00,
  "transaction_date": "2025-12-06",
  "description": "Initial deposit",
  "created_at": "2025-12-06T10:30:00.000000Z",
  "updated_at": "2025-12-06T10:30:00.000000Z"
}
```

#### Get Transactions Endpoint
**Route**: `GET /api/bank-transactions`

**Query Parameters**:
- `organization_id`: Filter by organization
- `account_id`: Filter by specific account
- `start_date`: Filter from date
- `end_date`: Filter to date

**Response**: Array of transactions with account details

### 3. Database Structure

#### bank_accounts Table
```sql
- id
- user_id
- organization_id
- account_name
- opening_balance
- as_of_date
- bank_account_no (nullable)
- ifsc_code (nullable)
- account_holder_name (nullable)
- upi_id (nullable)
- bank_name (nullable)
- branch_name (nullable)
- current_balance  ← Updated by transactions
- account_type (bank/cash)
- created_at
- updated_at
```

#### bank_transactions Table
```sql
- id
- user_id
- organization_id
- account_id
- transaction_type (add/reduce/transfer_in/transfer_out)
- amount
- transaction_date
- description (nullable)
- related_account_id (nullable, for transfers)
- related_transaction_id (nullable, for transfers)
- is_external_transfer (boolean)
- external_account_holder (nullable)
- external_account_number (nullable)
- external_bank_name (nullable)
- external_ifsc_code (nullable)
- created_at
- updated_at
```

## How It Works

### Add Money Flow
1. User clicks "Add/Reduce Money" button
2. Selects "Add Money" from dropdown
3. Chooses account (e.g., "Cash in Hand" or "HDFC Bank")
4. Enters amount (e.g., ₹5,000)
5. Selects date and adds description
6. Clicks "Save"
7. **Backend**:
   - Creates transaction record with type "add"
   - Increases account's `current_balance` by ₹5,000
8. **Frontend**:
   - Shows success message
   - Reloads accounts (updated balance visible)
   - Reloads transactions (new transaction appears in table)

### Reduce Money Flow
1. User clicks "Add/Reduce Money" button
2. Selects "Reduce Money" from dropdown
3. Chooses account
4. Enters amount (e.g., ₹2,000)
5. Selects date and adds description
6. Clicks "Save"
7. **Backend**:
   - Validates sufficient balance
   - Creates transaction record with type "reduce"
   - Decreases account's `current_balance` by ₹2,000
8. **Frontend**:
   - Shows success message
   - Reloads accounts (updated balance visible)
   - Reloads transactions (new transaction appears in table)

## Transaction Types

| Type | Icon | Color | Effect on Balance | Use Case |
|------|------|-------|-------------------|----------|
| Add Money | ➕ | Green | Increases | Deposit, Income received |
| Reduce Money | ➖ | Red | Decreases | Withdrawal, Expense paid |
| Transfer In | ⬇️ | Green | Increases | Money received from another account |
| Transfer Out | ⬆️ | Red | Decreases | Money sent to another account |

## Example Scenarios

### Scenario 1: Cash Deposit
- **Action**: Add Money to "Cash in Hand"
- **Amount**: ₹10,000
- **Result**: Cash in Hand balance increases from ₹5,000 to ₹15,000
- **Transaction**: Shows as "Add Money" with green badge

### Scenario 2: Bank Withdrawal
- **Action**: Reduce Money from "HDFC Bank"
- **Amount**: ₹3,000
- **Result**: HDFC Bank balance decreases from ₹50,000 to ₹47,000
- **Transaction**: Shows as "Reduce Money" with red badge

### Scenario 3: Expense Payment
- **Action**: Reduce Money from "Cash in Hand"
- **Amount**: ₹500
- **Description**: "Office supplies"
- **Result**: Cash in Hand balance decreases by ₹500
- **Transaction**: Shows as "Reduce Money" with description "Office supplies"

## Testing

### Test Add Money
1. Go to Cash and Bank screen
2. Click "Add/Reduce Money"
3. Select "Add Money"
4. Choose "Cash in Hand"
5. Enter amount: 1000
6. Click Save
7. Verify: Cash in Hand balance increased by ₹1,000
8. Verify: Transaction appears in table with green "Add Money" badge

### Test Reduce Money
1. Click "Add/Reduce Money"
2. Select "Reduce Money"
3. Choose a bank account
4. Enter amount: 500
5. Click Save
6. Verify: Bank account balance decreased by ₹500
7. Verify: Transaction appears in table with red "Reduce Money" badge

### Test Insufficient Balance
1. Try to reduce more money than available
2. Verify: Error message "Insufficient balance" appears
3. Verify: Transaction is not created

## API Endpoints Summary

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/bank-accounts` | Get all accounts with balances |
| POST | `/api/bank-accounts` | Create new account |
| GET | `/api/bank-transactions` | Get all transactions |
| POST | `/api/bank-transactions` | Add/Reduce money |
| POST | `/api/bank-transactions/transfer` | Transfer between accounts |

## Security Features
- ✅ User authentication required
- ✅ Account ownership verification
- ✅ Sufficient balance check for reduce operations
- ✅ Database transactions for data integrity
- ✅ Organization-level data isolation

## Benefits
1. **Real-time Balance Updates**: Account balances update immediately
2. **Complete Audit Trail**: All transactions are recorded with date and description
3. **Visual Clarity**: Color-coded badges and icons for easy identification
4. **Flexible Filtering**: Filter transactions by date range
5. **Multi-Account Support**: Works with both Cash and Bank accounts
6. **Organization Isolation**: Each organization's data is separate

The feature is now fully functional and ready to use!
