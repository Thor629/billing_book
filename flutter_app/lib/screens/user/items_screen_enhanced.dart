import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/item_provider.dart';
import '../../providers/organization_provider.dart';
import '../../models/item_model.dart';
import 'create_item_screen.dart';

class ItemsScreenEnhanced extends StatefulWidget {
  const ItemsScreenEnhanced({super.key});

  @override
  State<ItemsScreenEnhanced> createState() => _ItemsScreenEnhancedState();
}

class _ItemsScreenEnhancedState extends State<ItemsScreenEnhanced> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  bool _showLowStockOnly = false;
  final Set<int> _selectedItems = {};
  String _sortColumn = 'item_name';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadItems();
    });
  }

  Future<void> _loadItems() async {
    final orgProvider = Provider.of<OrganizationProvider>(
      context,
      listen: false,
    );
    if (orgProvider.selectedOrganization != null) {
      await Provider.of<ItemProvider>(
        context,
        listen: false,
      ).loadItems(orgProvider.selectedOrganization!.id);
    }
  }

  List<ItemModel> _getFilteredItems(List<ItemModel> items) {
    var filtered = items;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.itemName.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
            item.itemCode.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Category filter
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      filtered =
          filtered.where((item) => item.category == _selectedCategory).toList();
    }

    // Low stock filter
    if (_showLowStockOnly) {
      filtered = filtered.where((item) => item.isLowStock).toList();
    }

    // Sorting
    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortColumn) {
        case 'item_name':
          comparison = a.itemName.compareTo(b.itemName);
          break;
        case 'item_code':
          comparison = a.itemCode.compareTo(b.itemCode);
          break;
        case 'stock_qty':
          comparison = a.stockQty.compareTo(b.stockQty);
          break;
        case 'selling_price':
          comparison = a.sellingPrice.compareTo(b.sellingPrice);
          break;
        case 'purchase_price':
          comparison = a.purchasePrice.compareTo(b.purchasePrice);
          break;
        case 'mrp':
          comparison = a.mrp.compareTo(b.mrp);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  double _calculateStockValue(List<ItemModel> items) {
    return items.fold(
      0.0,
      (sum, item) => sum + (item.stockQty * item.purchasePrice),
    );
  }

  int _getLowStockCount(List<ItemModel> items) {
    return items.where((item) => item.isLowStock).length;
  }

  List<String> _getCategories(List<ItemModel> items) {
    final categories = items
        .where((item) => item.category != null && item.category!.isNotEmpty)
        .map((item) => item.category!)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Items', style: AppTextStyles.h1),
                Row(
                  children: [
                    _buildReportsButton(),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () {},
                      tooltip: 'Settings',
                    ),
                    IconButton(
                      icon: const Icon(Icons.view_module_outlined),
                      onPressed: () {},
                      tooltip: 'Change View',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Metrics Cards
            Consumer<ItemProvider>(
              builder: (context, itemProvider, _) {
                final stockValue = _calculateStockValue(itemProvider.items);
                final lowStockCount = _getLowStockCount(itemProvider.items);

                return Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Stock Value',
                        value: '₹${stockValue.toStringAsFixed(2)}',
                        icon: Icons.inventory_2_outlined,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Low Stock',
                        value: lowStockCount.toString(),
                        icon: Icons.warning_amber_outlined,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Action Bar
            Consumer<ItemProvider>(
              builder: (context, itemProvider, _) {
                final categories = _getCategories(itemProvider.items);

                return Row(
                  children: [
                    // Search
                    SizedBox(
                      width: 250,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search Item',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Category Filter
                    SizedBox(
                      width: 200,
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          hintText: 'Select Categories',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Categories'),
                          ),
                          ...categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedCategory = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Show Low Stock Toggle
                    Tooltip(
                      message: 'Show or hide items with low stock',
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(
                            () => _showLowStockOnly = !_showLowStockOnly,
                          );
                        },
                        icon: Icon(
                          _showLowStockOnly
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 18,
                        ),
                        label: const Text('Show Low Stock'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _showLowStockOnly
                              ? Colors.orange[50]
                              : Colors.white,
                          foregroundColor: _showLowStockOnly
                              ? Colors.orange[700]
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Spacer(),

                    // Bulk Actions
                    if (_selectedItems.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.checklist, size: 18),
                            const SizedBox(width: 8),
                            Text('Bulk Actions'),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _selectedItems.length.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    const SizedBox(width: 12),

                    // Create Item Button
                    ElevatedButton.icon(
                      onPressed: () {
                        _showCreateItemDialog();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Create Item'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Data Table
            Expanded(
              child: Consumer<ItemProvider>(
                builder: (context, itemProvider, _) {
                  if (itemProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (itemProvider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: AppColors.warning,
                          ),
                          const SizedBox(height: 16),
                          Text(itemProvider.error!),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadItems,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final filteredItems = _getFilteredItems(itemProvider.items);

                  if (filteredItems.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty || _selectedCategory != null
                                ? 'No items found'
                                : 'No items yet',
                            style: AppTextStyles.h3.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Card(
                    child: SizedBox(
                      width: double.infinity,
                      child: SingleChildScrollView(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: MediaQuery.of(context).size.width - 300,
                            ),
                            child: DataTable(
                              showCheckboxColumn: true,
                              columnSpacing: 40,
                              columns: [
                                _buildDataColumn('Item Name', 'item_name'),
                                _buildDataColumn('Item Code', 'item_code'),
                                _buildDataColumn('Stock QTY', 'stock_qty'),
                                _buildDataColumn(
                                    'Selling Price', 'selling_price'),
                                _buildDataColumn(
                                    'Purchase Price', 'purchase_price'),
                                _buildDataColumn('MRP', 'mrp'),
                                const DataColumn(label: Text('Actions')),
                              ],
                              rows: filteredItems.map((item) {
                                final isSelected =
                                    _selectedItems.contains(item.id);
                                return DataRow(
                                  selected: isSelected,
                                  onSelectChanged: (selected) {
                                    setState(() {
                                      if (selected == true) {
                                        _selectedItems.add(item.id);
                                      } else {
                                        _selectedItems.remove(item.id);
                                      }
                                    });
                                  },
                                  cells: [
                                    DataCell(Text(item.itemName)),
                                    DataCell(Text(item.itemCode)),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: item.isLowStock
                                              ? Colors.red[50]
                                              : Colors.green[50],
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '${item.stockQty} ${item.unit}',
                                          style: TextStyle(
                                            color: item.isLowStock
                                                ? Colors.red[700]
                                                : Colors.green[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '₹${item.sellingPrice.toStringAsFixed(2)}',
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '₹${item.purchasePrice.toStringAsFixed(2)}',
                                      ),
                                    ),
                                    DataCell(Text(
                                        '₹${item.mrp.toStringAsFixed(2)}')),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              size: 18,
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      CreateItemScreen(
                                                          item: item),
                                                ),
                                              ).then((_) => _loadItems());
                                            },
                                            tooltip: 'Edit',
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.more_vert,
                                              size: 18,
                                            ),
                                            onPressed: () {
                                              _showItemMenu(context, item);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedItems.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {},
              backgroundColor: Colors.green,
              icon: const Icon(Icons.check_circle_outline),
              label: Row(
                children: [
                  const Text('Pending Actions'),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _selectedItems.length.toString(),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  DataColumn _buildDataColumn(String label, String columnName) {
    return DataColumn(
      label: Text(label),
      onSort: (columnIndex, ascending) {
        setState(() {
          _sortColumn = columnName;
          _sortAscending = ascending;
        });
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value, style: AppTextStyles.h2),
              ],
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.open_in_new, size: 18),
              onPressed: () {},
              tooltip: 'View Details',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsButton() {
    return PopupMenuButton<String>(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.description_outlined, size: 18, color: Colors.blue[700]),
            const SizedBox(width: 8),
            Text('Reports', style: TextStyle(color: Colors.blue[700])),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'stock', child: Text('Stock Report')),
        const PopupMenuItem(value: 'sales', child: Text('Sales Report')),
        const PopupMenuItem(value: 'purchase', child: Text('Purchase Report')),
        const PopupMenuItem(
          value: 'low_stock',
          child: Text('Low Stock Report'),
        ),
      ],
      onSelected: (value) {
        // Handle report selection
      },
    );
  }

  void _showItemMenu(BuildContext context, ItemModel item) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
            child: FadeTransition(
              opacity: animation,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 250,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildMenuOption(
                        icon: Icons.visibility_outlined,
                        label: 'View',
                        onTap: () {
                          Navigator.pop(context);
                          _showItemDetails(item);
                        },
                      ),
                      const Divider(height: 1),
                      _buildMenuOption(
                        icon: Icons.edit_outlined,
                        label: 'Edit',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CreateItemScreen(item: item),
                            ),
                          ).then((_) => _loadItems());
                        },
                      ),
                      const Divider(height: 1),
                      _buildMenuOption(
                        icon: Icons.content_copy_outlined,
                        label: 'Duplicate',
                        onTap: () {
                          Navigator.pop(context);
                          _duplicateItem(item);
                        },
                      ),
                      const Divider(height: 1),
                      _buildMenuOption(
                        icon: Icons.delete_outline,
                        label: 'Delete',
                        color: AppColors.warning,
                        onTap: () {
                          Navigator.pop(context);
                          _deleteItem(item);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: color ?? AppColors.textPrimary, size: 22),
            const SizedBox(width: 16),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: color ?? AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _duplicateItem(ItemModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateItemScreen(
          item: ItemModel(
            id: 0,
            itemName: '${item.itemName} (Copy)',
            itemCode: '${item.itemCode}_COPY',
            sellingPrice: item.sellingPrice,
            sellingPriceWithTax: item.sellingPriceWithTax,
            purchasePrice: item.purchasePrice,
            purchasePriceWithTax: item.purchasePriceWithTax,
            mrp: item.mrp,
            stockQty: item.stockQty,
            openingStock: item.openingStock,
            unit: item.unit,
            lowStockAlert: item.lowStockAlert,
            enableLowStockWarning: item.enableLowStockWarning,
            category: item.category,
            description: item.description,
            hsnCode: item.hsnCode,
            gstRate: item.gstRate,
            isActive: item.isActive,
            organizationId: item.organizationId,
            createdAt: DateTime.now(),
          ),
        ),
      ),
    ).then((_) => _loadItems());
  }

  void _deleteItem(ItemModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.itemName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await Provider.of<ItemProvider>(
                  context,
                  listen: false,
                ).deleteItem(item.id);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showItemDetails(ItemModel item) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
            child: FadeTransition(
              opacity: animation,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  constraints: const BoxConstraints(maxWidth: 600),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.inventory_2, color: Colors.white),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.itemName,
                                style: AppTextStyles.h2.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      // Content
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow('Item Code', item.itemCode),
                            _buildDetailRow(
                                'Category', item.category ?? 'Not specified'),
                            _buildDetailRow('Unit', item.unit),
                            const Divider(height: 32),
                            Text('Pricing',
                                style: AppTextStyles.h3
                                    .copyWith(color: AppColors.primaryDark)),
                            const SizedBox(height: 12),
                            _buildDetailRow('Selling Price',
                                '₹${item.sellingPrice.toStringAsFixed(2)}'),
                            _buildDetailRow('Purchase Price',
                                '₹${item.purchasePrice.toStringAsFixed(2)}'),
                            _buildDetailRow(
                                'MRP', '₹${item.mrp.toStringAsFixed(2)}'),
                            _buildDetailRow('GST Rate', '${item.gstRate}%'),
                            const Divider(height: 32),
                            Text('Stock',
                                style: AppTextStyles.h3
                                    .copyWith(color: AppColors.primaryDark)),
                            const SizedBox(height: 12),
                            _buildDetailRow('Current Stock',
                                '${item.stockQty} ${item.unit}'),
                            _buildDetailRow('Low Stock Alert',
                                '${item.lowStockAlert} ${item.unit}'),
                            _buildDetailRow(
                                'Status',
                                item.isLowStock
                                    ? 'Low Stock ⚠️'
                                    : 'In Stock ✓'),
                            if (item.description != null &&
                                item.description!.isNotEmpty) ...[
                              const Divider(height: 32),
                              Text('Description',
                                  style: AppTextStyles.h3
                                      .copyWith(color: AppColors.primaryDark)),
                              const SizedBox(height: 12),
                              Text(item.description!,
                                  style: AppTextStyles.bodyMedium),
                            ],
                            if (item.hsnCode != null &&
                                item.hsnCode!.isNotEmpty) ...[
                              const Divider(height: 32),
                              _buildDetailRow('HSN Code', item.hsnCode!),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateItemDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
            child: FadeTransition(
              opacity: animation,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.9,
                  constraints: const BoxConstraints(
                    maxWidth: 1200,
                    maxHeight: 800,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: const CreateItemScreen(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ).then((_) => _loadItems());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
