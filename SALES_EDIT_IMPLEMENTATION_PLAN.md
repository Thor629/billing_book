# Sales Menu Edit Functionality Implementation Plan

## Overview
Add edit functionality to all Sales submenu screens following the Payment Out pattern.

## Screens to Update

### 1. ✅ Quotations - PLACEHOLDER ADDED
- Has edit button with "coming soon" message
- Needs full implementation (complex - has items)

### 2. 🔄 Sales Invoices - IN PROGRESS
- Added TableActionButtons with edit
- Needs create screen update (complex - has items)
- Needs backend update route

### 3. ⚠️ Sales Returns
- Has view/delete buttons
- Needs edit button added
- Needs create screen update
- Needs backend update route

### 4. ⚠️ Credit Notes
- Has view/delete buttons
- Needs edit button added
- Needs create screen update
- Needs backend update route

### 5. ⚠️ Delivery Challans
- Has view/delete buttons
- Needs edit button added
- Needs create screen update
- Needs backend update route

## Implementation Priority

### Phase 1: Simple Screens (No Items)
These are easier to implement:
1. **Payment In** (already started)
2. **Credit Notes**
3. **Delivery Challans**

### Phase 2: Complex Screens (With Items)
These require more work:
1. **Sales Invoices** (has items array)
2. **Quotations** (has items array)
3. **Sales Returns** (has items array)

## Pattern to Follow

### Frontend Changes (Per Screen):

#### 1. Update Create Screen
```dart
class CreateXScreen extends StatefulWidget {
  final int? recordId;
  final Map<String, dynamic>? recordData;

  const CreateXScreen({
    super.key,
    this.recordId,
    this.recordData,
  });
}
```

#### 2. Load Existing Data in _loadData()
```dart
setState(() {
  // ... load parties, items, etc
  
  // Load existing data if in edit mode
  if (widget.recordData != null) {
    _field1 = widget.recordData!['field1'];
    _controller.text = widget.recordData!['field2']?.toString() ?? '';
    // ... load all fields
  }
});
```

#### 3. Add _isEditMode Getter
```dart
bool get _isEditMode => widget.recordId != null || widget.recordData != null;
```

#### 4. Update Save Method
```dart
if (_isEditMode && widget.recordId != null) {
  await _service.updateX(widget.recordId!, data);
} else {
  await _service.createX(data);
}
```

#### 5. Update AppBar Title
```dart
title: Text(_isEditMode ? 'Edit X' : 'Create X'),
```

#### 6. Update List Screen Edit Method
```dart
void _editX(X record) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CreateXScreen(
        recordId: record.id,
        recordData: {
          'field1': record.field1,
          'field2': record.field2,
          // ... all fields
        },
      ),
    ),
  ).then((result) {
    if (result == true) {
      _loadRecords();
    }
  });
}
```

### Backend Changes (Per Screen):

#### 1. Add Route in api.php
```php
Route::put('/{id}', [XController::class, 'update']);
```

#### 2. Add Update Method in Controller
```php
public function update($id, Request $request)
{
    $record = X::where('organization_id', $request->header('X-Organization-Id'))
        ->findOrFail($id);

    $validated = $request->validate([
        // validation rules
    ]);

    $record->update($validated);

    return response()->json($record->load(['relationships']), 200);
}
```

#### 3. Add Update Method in Service
```dart
Future<X> updateX(int id, Map<String, dynamic> data) async {
  final response = await _apiClient.put('/x/$id', data);
  if (response.statusCode == 200) {
    return X.fromJson(json.decode(response.body));
  }
  throw Exception('Failed to update');
}
```

## Files to Modify Per Screen

### Example: Credit Notes

**Frontend:**
1. `flutter_app/lib/screens/user/create_credit_note_screen.dart` - Add edit mode
2. `flutter_app/lib/screens/user/credit_note_screen.dart` - Update edit handler
3. `flutter_app/lib/services/credit_note_service.dart` - Add update method

**Backend:**
4. `backend/routes/api.php` - Add PUT route
5. `backend/app/Http/Controllers/CreditNoteController.php` - Add update method

## Next Steps

1. Start with simpler screens (Credit Notes, Delivery Challans)
2. Test each implementation thoroughly
3. Move to complex screens (Sales Invoices, Quotations)
4. Document any issues or special cases

## Notes

- Complex screens with items arrays need special handling
- May need to handle item updates separately
- Consider whether to allow editing items or just header fields
- Test with real data to ensure relationships update correctly
