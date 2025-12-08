# Cash/Bank Account Type Selector Added

## What Changed

I've added a **new dropdown field** in the "Add/Reduce Money" dialog to first select between **Cash** or **Bank**, and then show only the relevant accounts.

## New Dialog Flow

### Before:
```
1. Transaction Type (Add/Reduce)
2. Select Account (shows ALL accounts mixed)
3. Amount
4. Date
5. Description
```

### After:
```
1. Transaction Type (Add/Reduce)
2. Account Type (Cash 💰 or Bank 🏦) ← NEW!
3. Select Account (shows ONLY Cash or Bank accounts based on step 2)
4. Amount
5. Date
6. Description
```

## Features Added

### 1. Account Type Selector
- **Dropdown with icons**:
  - 💰 Cash - Shows cash accounts
  - 🏦 Bank - Shows bank accounts
- **Default**: Cash is selected by default
- **Dynamic filtering**: Account list updates based on selection

### 2. Filtered Account List
- Shows **only Cash accounts** when "Cash" is selected
- Shows **only Bank accounts** when "Bank" is selected
- Displays **current balance** next to each account name
- Shows helper text if no accounts of that type exist

### 3. Smart Account Selection
- Automatically selects the first account when type changes
- Prevents showing empty dropdown
- Validates that an account is selected

## Visual Layout

```
┌─────────────────────────────────────────┐
│ Add/Reduce Money                        │
├─────────────────────────────────────────┤
│                                         │
│ Transaction Type *                      │
│ ┌─────────────────────────────────────┐ │
│ │ Add Money                        ▼  │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ Account Type *                          │
│ ┌─────────────────────────────────────┐ │
│ │ 💰 Cash                          ▼  │ │ ← NEW!
│ └─────────────────────────────────────┘ │
│                                         │
│ Select Cash Account *                   │
│ ┌─────────────────────────────────────┐ │
│ │ Cash in Hand          ₹10,000    ▼  │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ Amount *                                │
│ ┌─────────────────────────────────────┐ │
│ │ ₹                                   │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ Date *                                  │
│ ┌─────────────────────────────────────┐ │
│ │ 2025-12-06                      📅  │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ Description                             │
│ ┌─────────────────────────────────────┐ │
│ │                                     │ │
│ │                                     │ │
│ └─────────────────────────────────────┘ │
│                                         │
│              [Cancel]  [Save]           │
└─────────────────────────────────────────┘
```

## Example Usage

### Scenario 1: Add Money to Cash
1. Click "Add/Reduce Money"
2. Select "Add Money"
3. Select "💰 Cash" ← Shows only cash accounts
4. Select "Cash in Hand (₹5,000)"
5. Enter amount: 1000
6. Click Save
7. **Result**: Cash in Hand balance becomes ₹6,000

### Scenario 2: Reduce Money from Bank
1. Click "Add/Reduce Money"
2. Select "Reduce Money"
3. Select "🏦 Bank" ← Shows only bank accounts
4. Select "HDFC Bank (₹50,000)"
5. Enter amount: 2000
6. Click Save
7. **Result**: HDFC Bank balance becomes ₹48,000

## Code Changes

### File: `flutter_app/lib/screens/user/cash_bank_screen.dart`

#### Added State Variable:
```dart
String _accountTypeFilter = 'cash'; // 'cash' or 'bank'
```

#### Added Filtered Accounts Getter:
```dart
List<BankAccount> get _filteredAccounts {
  return widget.accounts
      .where((account) => account.accountType == _accountTypeFilter)
      .toList();
}
```

#### Added Account Type Dropdown:
- Icon-based dropdown (💰 Cash / 🏦 Bank)
- Updates filtered account list on change
- Auto-selects first account of new type

#### Updated Account Dropdown:
- Shows only filtered accounts
- Displays current balance
- Dynamic label based on type
- Helper text when no accounts available

## Benefits

✅ **Clearer Selection**: Users know if they're working with Cash or Bank
✅ **Reduced Confusion**: No mixing of cash and bank accounts
✅ **Better UX**: Visual icons make it intuitive
✅ **Shows Balance**: Users can see current balance before selecting
✅ **Prevents Errors**: Can't accidentally select wrong account type
✅ **Organized**: Separates cash and bank operations

## How to Test

### Step 1: Restart Flutter App
```bash
cd flutter_app
flutter clean
flutter pub get
flutter run
```

### Step 2: Open Add/Reduce Money Dialog
1. Go to Cash and Bank screen
2. Click "Add/Reduce Money" button

### Step 3: Verify New Dropdown
You should see:
- ✅ "Account Type *" dropdown with Cash/Bank options
- ✅ Icons (💰 for Cash, 🏦 for Bank)
- ✅ Account list changes when you switch types
- ✅ Current balance shown next to account names

### Step 4: Test Cash Selection
1. Select "💰 Cash"
2. Verify: Only "Cash in Hand" appears in account dropdown
3. Add money and verify balance updates

### Step 5: Test Bank Selection
1. Select "🏦 Bank"
2. Verify: Only bank accounts appear (HDFC, SBI, etc.)
3. Reduce money and verify balance updates

## Database Structure (No Changes)

The database structure remains the same:
- `bank_accounts` table has `account_type` column ('cash' or 'bank')
- Frontend now filters based on this column
- Backend API unchanged

## API (No Changes)

All existing APIs work the same:
- `POST /api/bank-transactions` - Add/Reduce money
- `GET /api/bank-accounts` - Get all accounts
- Backend doesn't need any changes

## Summary

The Add/Reduce Money dialog now has a **3-step selection process**:
1. **What to do**: Add or Reduce
2. **Where**: Cash or Bank ← NEW!
3. **Which account**: Specific account from filtered list

This makes it much clearer and prevents confusion between cash and bank accounts!
