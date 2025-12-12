# Party Name Not Showing - Troubleshooting Guide

## Issue
Party name still not showing in the dropdown when editing Payment In.

## Code Changes Made

### 1. List Screen - Passing party_name ✅
```dart
paymentData: {
  'payment_number': payment.paymentNumber,
  'party_id': payment.party?.id,
  'party_name': payment.party?.name,  // ✅ Added
  'amount': payment.amount,
  'payment_mode': payment.paymentMode,
  'payment_date': payment.paymentDate.toIso8601String(),
  'notes': payment.notes,
},
```

### 2. Create Screen - Loading party_name ✅
```dart
if (widget.paymentData != null) {
  _selectedPartyId = widget.paymentData!['party_id'];
  _selectedPartyName = widget.paymentData!['party_name'];  // ✅ Added
  // ... other fields
}
```

### 3. Debug Logging Added ✅
```dart
debugPrint('🔄 Loading payment data: ${widget.paymentData}');
// ... load data
debugPrint('✅ Loaded party: ID=$_selectedPartyId, Name=$_selectedPartyName');
```

## Troubleshooting Steps

### Step 1: Restart the App
Hot reload might not be enough for this change. Try:
1. Stop the app completely
2. Run `flutter clean` (optional but recommended)
3. Restart the app

### Step 2: Check Debug Console
When you click edit, you should see in the console:
```
🔄 Loading payment data: {payment_number: PI-000084, party_id: 1, party_name: John Doe, ...}
✅ Loaded party: ID=1, Name=John Doe
```

If you see `party_name: null`, the issue is in the data source.

### Step 3: Verify Party Data
Check if the payment record has party data:
```dart
// In payment_in_screen.dart _editPayment method
debugPrint('Payment party: ${payment.party?.name}');
```

### Step 4: Check Payment Model
Verify the PaymentIn model has the party relationship loaded:
```dart
// The payment should have:
payment.party?.id    // Should not be null
payment.party?.name  // Should not be null
```

## Possible Issues

### Issue 1: Party Not Loaded from Backend
**Symptom:** `payment.party` is null

**Solution:** Check backend API response includes party relationship:
```php
// In PaymentInController.php
return PaymentIn::with(['party'])->get();  // ✅ Must include 'party'
```

### Issue 2: Hot Reload Not Applying Changes
**Symptom:** Code looks correct but behavior unchanged

**Solution:** 
1. Stop app
2. Run: `flutter clean`
3. Restart app

### Issue 3: Party Name is Null in Database
**Symptom:** Debug shows `party_name: null`

**Solution:** Check if the party record exists and has a name in the database.

### Issue 4: Wrong Field Name
**Symptom:** Debug shows party data but name still not displaying

**Solution:** Verify the dropdown is using `_selectedPartyName`:
```dart
Text(
  _selectedPartyName ?? 'Search party by name or number',
  // ...
)
```

## Quick Test

Add this temporary code to verify data flow:

```dart
// In create_payment_in_screen.dart, in build method
if (_isEditMode) {
  print('EDIT MODE: Party ID=$_selectedPartyId, Name=$_selectedPartyName');
}
```

## Expected Behavior

When clicking edit on a payment:
1. Screen opens with title "Edit Payment In"
2. Party dropdown shows the party name (e.g., "John Doe")
3. All other fields are pre-filled
4. Debug console shows the loading messages

## If Still Not Working

1. **Check the debug output** - What does it show?
2. **Verify backend response** - Does it include party data?
3. **Check party model** - Is the relationship defined?
4. **Try creating a new payment** - Does party selection work for new payments?

## Files to Check

1. `flutter_app/lib/screens/user/payment_in_screen.dart` - Line ~370
2. `flutter_app/lib/screens/user/create_payment_in_screen.dart` - Line ~65
3. `flutter_app/lib/models/payment_in_model.dart` - Check party field
4. `backend/app/Http/Controllers/PaymentInController.php` - Check with(['party'])

## Next Steps

1. Restart the app completely
2. Click edit on a payment
3. Check debug console for the messages
4. Share the debug output if issue persists

The code changes are correct. The issue is likely:
- App needs restart (most common)
- Party data not loaded from backend
- Party name is null in the database
