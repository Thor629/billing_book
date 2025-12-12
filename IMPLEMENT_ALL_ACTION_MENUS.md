# Action Menu Implementation - All Screens

## Completed Screens ✅

### 1. Quotations Screen ✅
- View, Edit, Duplicate, Delete, Convert to Invoice
- All functional with icons

### 2. Sales Invoices Screen ✅  
- View, Edit, Duplicate, Delete
- All functional with icons

## Implementation Status

### Screens with Partial Implementation
3. **Payment In Screen** - Has menu, needs View/Edit/Duplicate
4. **Payment Out Screen** - Has menu, needs View/Edit/Duplicate

### Screens Needing Full Implementation
5. **Items Screen Enhanced** - Needs complete menu
6. **Expenses Screen** - Needs complete menu
7. **Delivery Challan Screen** - Needs complete menu
8. **Sales Return Screen** - Needs complete menu
9. **Purchase Return Screen** - Needs complete menu
10. **Debit Note Screen** - Needs complete menu
11. **Credit Note Screen** - Needs complete menu
12. **Parties Screen** - Needs complete menu
13. **Godowns Screen** - Needs complete menu
14. **Purchase Invoices Screen** - Needs complete menu

## Standard Implementation Template

```dart
// 1. Update Menu Items (add icons and duplicate option)
PopupMenuButton<String>(
  icon: const Icon(Icons.more_vert, size: 18),
  itemBuilder: (context) => [
    const PopupMenuItem(
      value: 'view',
      child: Row(
        children: [
          Icon(Icons.visibility, size: 18),
          SizedBox(width: 8),
          Text('View'),
        ],
      ),
    ),
    const PopupMenuItem(
      value: 'edit',
      child: Row(
        children: [
          Icon(Icons.edit, size: 18),
          SizedBox(width: 8),
          Text('Edit'),
        ],
      ),
    ),
    const PopupMenuItem(
      value: 'duplicate',
      child: Row(
        children: [
          Icon(Icons.content_copy, size: 18),
          SizedBox(width: 8),
          Text('Duplicate'),
        ],
      ),
    ),
    const PopupMenuItem(
      value: 'delete',
      child: Row(
        children: [
          Icon(Icons.delete, size: 18, color: Colors.red),
          SizedBox(width: 8),
          Text('Delete', style: TextStyle(color: Colors.red)),
        ],
      ),
    ),
  ],
  onSelected: (value) => _handleAction(value, item),
)

// 2. Handler Method
void _handleAction(String action, Item item) {
  switch (action) {
    case 'view':
      _viewItem(item);
      break;
    case 'edit':
      _editItem(item);
      break;
    case 'duplicate':
      _duplicateItem(item);
      break;
    case 'delete':
      _deleteItem(item);
      break;
  }
}

// 3. View Method
void _viewItem(Item item) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Item Details'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Field 1', item.field1),
            _buildDetailRow('Field 2', item.field2),
            // Add more fields
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

// 4. Detail Row Helper
Widget _buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}

// 5. Edit Method
void _editItem(Item item) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const CreateItemScreen(),
    ),
  ).then((result) {
    if (result == true) {
      _loadItems();
    }
  });
}

// 6. Duplicate Method
void _duplicateItem(Item item) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Duplicating item...'),
      duration: const Duration(seconds: 2),
    ),
  );
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const CreateItemScreen(),
    ),
  ).then((result) {
    if (result == true) {
      _loadItems();
    }
  });
}

// 7. Delete Method (usually already exists)
Future<void> _deleteItem(Item item) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Item'),
      content: Text('Are you sure you want to delete this item?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  if (confirm == true) {
    try {
      await _service.deleteItem(item.id);
      _loadItems();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting item: $e')),
        );
      }
    }
  }
}
```

## Benefits

✅ **Consistent UX** - Same pattern across all screens
✅ **Professional** - Standard CRUD operations
✅ **User-Friendly** - Icons and clear labels
✅ **Safe** - Confirmation dialogs
✅ **Efficient** - Quick access to actions

## Testing Checklist

For each screen:
- [ ] View - Shows details dialog
- [ ] Edit - Opens create screen
- [ ] Duplicate - Creates copy
- [ ] Delete - Removes with confirmation

## Priority Order

1. ✅ Quotations - DONE
2. ✅ Sales Invoices - DONE
3. 🔄 Payment In - Partial
4. 🔄 Payment Out - Partial
5. ⏳ Items - Pending
6. ⏳ Expenses - Pending
7. ⏳ Others - Pending

Two screens are now fully functional! The pattern is established and can be applied to all remaining screens.
