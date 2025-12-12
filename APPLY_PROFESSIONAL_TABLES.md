# Apply Professional Data Tables to All Screens

## Screens to Update (13 total)

### ✅ Already Updated
1. Payment In Screen - Done

### 🔄 To Update
2. Sales Invoices Screen
3. Sales Return Screen
4. Quotations Screen
5. Purchase Return Screen
6. Parties Screen
7. Items Screen
8. Godowns Screen
9. Expenses Screen
10. Items Screen Enhanced
11. Delivery Challan Screen
12. Debit Note Screen
13. Credit Note Screen

## Standard Update Pattern

### Step 1: Add Import
```dart
import '../../widgets/professional_data_table.dart';
```

### Step 2: Replace DataTable with ProfessionalDataTable
```dart
ProfessionalDataTable(
  columns: const [
    DataColumn(label: TableHeaderText('Column 1')),
    DataColumn(label: TableHeaderText('Column 2')),
    // ... more columns
  ],
  rows: _buildRows(),
)
```

### Step 3: Update Row Builder
```dart
List<DataRow> _buildRows() {
  return items.map((item) {
    return DataRow(
      cells: [
        DataCell(TableCellText(item.field1)),
        DataCell(TableCellText(item.field2)),
        DataCell(StatusBadge(status: item.status)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ActionButton(
                icon: Icons.visibility_outlined,
                onPressed: () {},
                tooltip: 'View',
              ),
              const SizedBox(width: 4),
              ActionButton(
                icon: Icons.delete_outline,
                onPressed: () {},
                color: AppColors.error,
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ],
    );
  }).toList();
}
```

## Execution Plan

I will update all 12 remaining screens in batches of 3-4 screens at a time to ensure quality and avoid errors.

### Batch 1: Sales Screens (3)
- Sales Invoices
- Sales Return  
- Quotations

### Batch 2: Purchase Screens (1)
- Purchase Return

### Batch 3: Master Data (3)
- Parties
- Items
- Godowns

### Batch 4: Transactions (3)
- Expenses
- Delivery Challan
- Items Enhanced

### Batch 5: Notes (2)
- Debit Note
- Credit Note
