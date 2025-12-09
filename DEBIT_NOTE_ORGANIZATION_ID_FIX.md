# Debit Note Organization ID Fix ✅

## Problem
When creating a debit note, the backend was receiving a null `organization_id`, causing an integrity constraint violation error:

```
SQLSTATE[23000]: Integrity constraint violation: 1048 Column 'organization_id' cannot be null
```

## Root Cause
The backend controller gets `organization_id` from the **request header** (`X-Organization-Id`), not from the request body:

```php
$debitNote = DebitNote::create([
    'organization_id' => $request->header('X-Organization-Id'),
    // ...
]);
```

However, the debit note service was not sending this header, unlike other services (purchase_return, purchase_invoice, payment_out).

## Solution

### 1. Updated DebitNoteService ✅
**File:** `flutter_app/lib/services/debit_note_service.dart`

**Changes:**
- Added `organizationId` parameter to all methods
- Added `X-Organization-Id` custom header to all API calls
- Removed `organization_id` from query parameters

**Before:**
```dart
Future<DebitNote> createDebitNote(Map<String, dynamic> debitNoteData) async {
  final response = await _apiClient.post('/debit-notes', debitNoteData);
  // ...
}
```

**After:**
```dart
Future<DebitNote> createDebitNote(
    int organizationId, Map<String, dynamic> debitNoteData) async {
  final response = await _apiClient.post(
    '/debit-notes',
    debitNoteData,
    customHeaders: {'X-Organization-Id': organizationId.toString()},
  );
  // ...
}
```

**Updated Methods:**
- `getDebitNotes()` - Added header, removed from query params
- `getDebitNote()` - Added organizationId parameter and header
- `createDebitNote()` - Added organizationId parameter and header
- `deleteDebitNote()` - Added organizationId parameter and header
- `getNextDebitNoteNumber()` - Added header, removed from query params

### 2. Updated CreateDebitNoteScreen ✅
**File:** `flutter_app/lib/screens/user/create_debit_note_screen.dart`

**Changes:**
- Removed `organization_id` from request body
- Pass `organizationId` to service method

**Before:**
```dart
final debitNoteData = {
  'organization_id': orgProvider.selectedOrganization!.id,
  'party_id': _selectedPartyId,
  // ...
};

await _debitNoteService.createDebitNote(debitNoteData);
```

**After:**
```dart
final debitNoteData = {
  'party_id': _selectedPartyId,
  // ... (no organization_id)
};

await _debitNoteService.createDebitNote(
  orgProvider.selectedOrganization!.id,
  debitNoteData,
);
```

### 3. Updated DebitNoteScreen ✅
**File:** `flutter_app/lib/screens/user/debit_note_screen.dart`

**Changes:**
- Pass `organizationId` to delete method

**Before:**
```dart
await _debitNoteService.deleteDebitNote(id);
```

**After:**
```dart
await _debitNoteService.deleteDebitNote(
  id,
  orgProvider.selectedOrganization!.id,
);
```

## How It Works Now

### Request Flow
```
Flutter App
  ↓
DebitNoteService.createDebitNote(organizationId, data)
  ↓
ApiClient.post('/debit-notes', data, headers: {'X-Organization-Id': '1'})
  ↓
Backend receives:
  - Headers: X-Organization-Id: 1
  - Body: { party_id, debit_note_number, ... }
  ↓
Controller: $request->header('X-Organization-Id')
  ↓
Database: organization_id = 1 ✅
```

## Consistency with Other Services

This fix makes the debit note service consistent with other services:

| Service | Uses X-Organization-Id Header |
|---------|-------------------------------|
| Purchase Return | ✅ Yes |
| Purchase Invoice | ✅ Yes |
| Payment Out | ✅ Yes |
| **Debit Note** | ✅ **Yes (Fixed)** |
| Credit Note | ❌ No (needs fixing) |

## Testing

### Test Case 1: Create Debit Note
1. Navigate to Debit Note screen
2. Click "Create Debit Note"
3. Fill in all fields:
   - Select supplier
   - Add reason
   - Add items
   - Enter payment details
4. Click "Save"
5. **Expected:** Debit note created successfully ✅
6. **Verify:** Check Cash & Bank for transaction

### Test Case 2: Delete Debit Note
1. Navigate to Debit Note screen
2. Click "..." menu on a debit note
3. Click "Delete"
4. Confirm deletion
5. **Expected:** Debit note deleted successfully ✅

## Summary

✅ **Service Updated** - All methods now send X-Organization-Id header
✅ **Create Screen Updated** - Passes organizationId to service
✅ **List Screen Updated** - Passes organizationId to delete method
✅ **Compilation Verified** - No errors
✅ **Consistent with Other Services** - Follows same pattern

**Status:** Fixed - Ready for Testing
**Last Updated:** December 9, 2024
