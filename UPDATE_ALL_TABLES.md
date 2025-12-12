# Batch Update Script for All Data Tables

## Screens to Update

### 1. Payment In Screen
### 2. Payment Out Screen  
### 3. Sales Return Screen
### 4. Credit Note Screen
### 5. Debit Note Screen
### 6. Purchase Return Screen
### 7. Delivery Challan Screen
### 8. Expenses Screen
### 9. Parties Screen
### 10. Godowns Screen
### 11. Items Screen (basic)
### 12. Purchase Invoices Screen

## Standard Pattern

### Add Import
```dart
import '../../widgets/modern_table_widgets.dart';
```

### Replace Card/Container with:
```dart
Container(
  decoration: BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.borderLight, width: 1),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowLight,
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 1000),
          child: DataTable(
            showCheckboxColumn: false,
            columnSpacing: 50,
            headingRowHeight: 56,
            dataRowMinHeight: 64,
            dataRowMaxHeight: 72,
            headingRowColor: WidgetStateProperty.all(AppColors.tableHeader),
            columns: [...],
            rows: [...],
          ),
        ),
      ),
    ),
  ),
)
```

### Update Headers
```dart
DataColumn(label: Text('Column Name', style: AppTextStyles.tableHeader))
```

### Update Cells
```dart
DataCell(ModernTableCell(text: 'Value'))
```

### Update Status
```dart
DataCell(ModernStatusBadge(status: item.status))
```

### Update Actions
```dart
DataCell(
  Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      ModernActionButton(
        icon: Icons.visibility_outlined,
        onPressed: () {},
        tooltip: 'View',
      ),
      const SizedBox(width: 4),
      ModernActionButton(
        icon: Icons.delete_outline,
        onPressed: () {},
        color: AppColors.error,
        tooltip: 'Delete',
      ),
    ],
  ),
)
```
