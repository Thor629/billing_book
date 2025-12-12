# Credit Note Edit Debug Guide

## Issue
Getting "Credit note number already exists" error when editing a credit note.

## Debug Steps

### 1. Check Flutter Console Output
When you click Save on edit, check the Flutter console for:
```
=== CREDIT NOTE SAVE DEBUG ===
Is Edit Mode: true
Credit Note ID: <number>
Credit Note Number: <number>
Calling UPDATE endpoint with ID: <number>
```

If you see "Calling CREATE endpoint" instead, the edit mode detection is failing.

### 2. Check Backend Logs
Check `backend/storage/logs/laravel.log` for:
```
Credit Note Update Request: {id: X, body: {...}}
```

This will show which endpoint is being hit.

### 3. Verify API Route
The update should go to: `PUT /api/credit-notes/{id}`

### 4. Test with Postman/cURL

**Update Credit Note:**
```bash
curl -X PUT http://localhost:8000/api/credit-notes/10 \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "amount_received": 500,
    "payment_mode": "cash",
    "status": "issued"
  }'
```

## Expected Behavior

1. Flutter detects edit mode (`_isEditMode = true`)
2. Calls `updateCreditNote(id, data)` 
3. Service calls `PUT /api/credit-notes/{id}`
4. Backend updates record without checking credit_note_number uniqueness
5. Bank balance automatically adjusted

## Common Issues

### Issue 1: Edit Mode Not Detected
**Symptom**: Console shows "Calling CREATE endpoint"
**Fix**: Ensure `creditNoteId` is passed when navigating to edit screen

### Issue 2: Wrong Endpoint Called
**Symptom**: Backend logs show POST instead of PUT
**Fix**: Check API client PUT method

### Issue 3: Validation Error
**Symptom**: "Credit note number already exists"
**Fix**: Backend should not validate uniqueness on update

## Quick Fix

If still getting error, try removing `credit_note_number` from update data:

**In Flutter** (`create_credit_note_screen.dart`):
```dart
final creditNoteData = {
  // Don't send credit_note_number on update
  if (!_isEditMode) 'credit_note_number': _creditNoteNumberController.text,
  'organization_id': orgProvider.selectedOrganization!.id,
  // ... rest of data
};
```

## Restart Backend

After backend changes:
```bash
cd backend
php artisan config:clear
php artisan cache:clear
php artisan serve
```

## Hot Restart Flutter

After Flutter changes:
- Press `R` in terminal (hot reload)
- Or press `Shift + R` (hot restart)
