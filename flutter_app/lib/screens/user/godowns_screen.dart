import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/godown_provider.dart';
import '../../providers/organization_provider.dart';
import '../../models/godown_model.dart';

class GodownsScreen extends StatefulWidget {
  const GodownsScreen({super.key});

  @override
  State<GodownsScreen> createState() => _GodownsScreenState();
}

class _GodownsScreenState extends State<GodownsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGodowns();
    });
  }

  Future<void> _loadGodowns() async {
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);
    if (orgProvider.selectedOrganization != null) {
      await Provider.of<GodownProvider>(context, listen: false)
          .loadGodowns(orgProvider.selectedOrganization!.id);
    }
  }

  void _showGodownDialog({GodownModel? godown}) {
    final nameController = TextEditingController(text: godown?.name ?? '');
    final codeController = TextEditingController(text: godown?.code ?? '');
    final addressController =
        TextEditingController(text: godown?.address ?? '');
    final contactPersonController = TextEditingController(
      text: godown?.contactPerson ?? '',
    );
    final phoneController = TextEditingController(
      text: godown?.phone ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(godown == null ? 'Add Warehouse' : 'Edit Warehouse'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Warehouse Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: 'Warehouse Code *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contactPersonController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Person',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || codeController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill required fields')),
                );
                return;
              }

              final godownData = {
                'name': nameController.text,
                'code': codeController.text,
                'address': addressController.text,
                'contact_person': contactPersonController.text,
                'phone': phoneController.text,
              };

              try {
                if (godown == null) {
                  await Provider.of<GodownProvider>(context, listen: false)
                      .createGodown(godownData);
                } else {
                  await Provider.of<GodownProvider>(context, listen: false)
                      .updateGodown(godown.id, godownData);
                }
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(godown == null
                          ? 'Warehouse created successfully'
                          : 'Warehouse updated successfully'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: Text(godown == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _showActionsMenu(BuildContext context, GodownModel godown) {
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
                        icon: Icons.edit_outlined,
                        label: 'Edit',
                        onTap: () {
                          Navigator.pop(context);
                          _showGodownDialog(godown: godown);
                        },
                      ),
                      const Divider(height: 1),
                      _buildMenuOption(
                        icon: Icons.content_copy_outlined,
                        label: 'Duplicate',
                        onTap: () {
                          Navigator.pop(context);
                          _duplicateGodown(godown);
                        },
                      ),
                      const Divider(height: 1),
                      _buildMenuOption(
                        icon: Icons.delete_outline,
                        label: 'Delete',
                        color: AppColors.warning,
                        onTap: () {
                          Navigator.pop(context);
                          _deleteGodown(godown);
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

  void _duplicateGodown(GodownModel godown) {
    final nameController = TextEditingController(text: '${godown.name} (Copy)');
    final codeController = TextEditingController(text: '${godown.code}_COPY');
    final addressController = TextEditingController(text: godown.address ?? '');
    final contactPersonController =
        TextEditingController(text: godown.contactPerson ?? '');
    final phoneController = TextEditingController(text: godown.phone ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duplicate Warehouse'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Warehouse Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: 'Warehouse Code *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contactPersonController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Person',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || codeController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill required fields')),
                );
                return;
              }

              final godownData = {
                'name': nameController.text,
                'code': codeController.text,
                'address': addressController.text,
                'contact_person': contactPersonController.text,
                'phone': phoneController.text,
              };

              try {
                await Provider.of<GodownProvider>(context, listen: false)
                    .createGodown(godownData);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Warehouse duplicated successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Duplicate'),
          ),
        ],
      ),
    );
  }

  void _deleteGodown(GodownModel godown) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Warehouse'),
        content: Text('Are you sure you want to delete "${godown.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await Provider.of<GodownProvider>(context, listen: false)
                    .deleteGodown(godown.id);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Warehouse deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Warehouses', style: AppTextStyles.h1),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your warehouses and storage locations',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showGodownDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add Warehouse'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Consumer<GodownProvider>(
              builder: (context, godownProvider, _) {
                if (godownProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (godownProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: AppColors.warning),
                        const SizedBox(height: 16),
                        Text(godownProvider.error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadGodowns,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (godownProvider.godowns.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.warehouse_outlined,
                            size: 64, color: AppColors.textSecondary),
                        const SizedBox(height: 16),
                        Text(
                          'No warehouses yet',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first warehouse to get started',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Card(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Code')),
                        DataColumn(label: Text('Address')),
                        DataColumn(label: Text('Contact Person')),
                        DataColumn(label: Text('Phone')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: godownProvider.godowns.map((godown) {
                        return DataRow(
                          cells: [
                            DataCell(Text(godown.name,
                                style: AppTextStyles.bodyMedium)),
                            DataCell(Text(godown.code)),
                            DataCell(Text(godown.address ?? '-')),
                            DataCell(Text(godown.contactPerson ?? '-')),
                            DataCell(Text(godown.phone ?? '-')),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: godown.isActive
                                      ? AppColors.success.withValues(alpha: 0.1)
                                      : AppColors.warning
                                          .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  godown.isActive ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    color: godown.isActive
                                        ? AppColors.success
                                        : AppColors.warning,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () =>
                                    _showActionsMenu(context, godown),
                                tooltip: 'Actions',
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
