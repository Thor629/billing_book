# Party Name Display Fix - Complete

## Issue
When editing Payment In, the party name was not showing in the dropdown field. Only the party ID was loaded, but not the display name.

## Root Cause
The `paymentData` map passed to the create screen only included `party_id` but not `party_name`. The create screen needs both:
- `party_id` - to identify which party is selected
- `party_name` - to display in the dropdown/search field

## Solution

### 1. Updated List Screen (`payment_in_screen.dart`)
Added `party_name` to the data being passed:

```dart
paymentData: {
  'payment_number': payment.paymentNumber,
  'party_id': payment.party?.id,
  'party_name': payment.party?.name,  // ✅ ADDED
  'amount': payment.amount,
  'payment_mode': payment.paymentMode,
  'payment_date': payment.paymentDate.toIso8601String(),
  'notes': payment.notes,
},
```

### 2. Updated Create Screen (`create_payment_in_screen.dart`)
Added loading of `_selectedPartyName`:

```dart
if (widget.paymentData != null) {
  _paymentNumberController.text = widget.paymentData!['payment_number'] ?? _paymentNumberController.text;
  _selectedPartyId = widget.paymentData!['party_id'];
  _selectedPartyName = widget.paymentData!['party_name'];  // ✅ ADDED
  _amountController.text = widget.paymentData!['amount']?.toString() ?? '';
  // ... rest of fields
}
```

## Result

✅ **Party name now displays correctly when editing Payment In**

When clicking edit:
1. Screen opens with "Edit Payment In" title
2. Party dropdown shows the party name (not just blank)
3. All other fields are pre-filled
4. User can modify and save

## Files Modified

1. `flutter_app/lib/screens/user/payment_in_screen.dart` - Added party_name to paymentData
2. `flutter_app/lib/screens/user/create_payment_in_screen.dart` - Load party_name into _selectedPartyName

## Testing

- [x] Edit button opens screen
- [x] Party name displays in dropdown
- [x] All fields pre-filled
- [x] Can save changes
- [x] Updates correctly

## Note on Payment Out

Payment Out may use a different approach for displaying party names (possibly loading parties list and matching by ID). If Payment Out has the same issue, the same fix can be applied.

## Pattern for Other Screens

When implementing edit for other screens, remember to pass both:
- `xxx_id` - The ID for selection
- `xxx_name` - The name for display

This applies to:
- Party selection
- Bank account selection
- Item selection
- Any dropdown/search field

## Status

✅ **FIXED - Party name now displays correctly in Payment In edit mode**
