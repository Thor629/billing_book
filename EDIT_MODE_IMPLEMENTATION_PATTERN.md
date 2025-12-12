# Edit Mode Implementation Pattern

## Pattern Applied to Quotations Screen ✅

This pattern needs to be applied to all 8 create screens.

### Step 1: Add Edit Mode Detection
```dart
bool get _isEditMode => widget.recordId != null || widget.recordData != null;
```

### Step 2: Add Data Loading Method
```dart
Future<void> _loadInitialData() async {
  if (widget.recordData != null) {
    setState(() {
      // Pre-fill form fields from recordData
      if (widget.recordData!['field_name'] != null) {
        _controller.text = widget.recordData!['field_name'].toString();
      }
      // ... load other fields
    });
  }
}
```

### Step 3: Call in initState
```dart
@override
void initState() {
  super.initState();
  _loadInitialData();  // Add this
  // ... other init methods
}
```

### Step 4: Skip Auto-Number in Edit Mode
```dart
Future<void> _loadNextNumber() async {
  // Don't load next number if in edit mode
  if (_isEditMode) return;
  
  // ... load next number logic
}
```

### Step 5: Update Title
```dart
title: Text(
  _isEditMode ? 'Edit Record' : 'Create Record',
  style: const TextStyle(color: Colors.black),
),
```

### Step 6: Update Save Logic (if needed)
```dart
Future<void> _save() async {
  if (_isEditMode && widget.recordId != null) {
    await service.update(widget.recordId!, data);
  } else {
    await service.create(data);
  }
}
```

---

## Screens to Update

1. ✅ Quotations - DONE
2. ⏳ Sales Invoices
3. ⏳ Sales Returns
4. ⏳ Credit Notes
5. ⏳ Delivery Challans
6. ⏳ Debit Notes
7. ⏳ Purchase Invoices
8. ⏳ Purchase Returns

---

## Implementation for Each Screen

I'll now apply this pattern to all remaining 7 screens.
