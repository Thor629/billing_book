import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/party_provider.dart';
import '../../providers/organization_provider.dart';
import '../../models/party_model.dart';

class PartiesScreen extends StatefulWidget {
  const PartiesScreen({super.key});

  @override
  State<PartiesScreen> createState() => _PartiesScreenState();
}

class _PartiesScreenState extends State<PartiesScreen> {
  @override
  void initState() {
    super.initState();
    _loadParties();
  }

  Future<void> _loadParties() async {
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);
    final partyProvider = Provider.of<PartyProvider>(context, listen: false);

    if (orgProvider.selectedOrganization != null) {
      await partyProvider.loadParties(orgProvider.selectedOrganization!.id);
    }
  }

  void _showPartyDialog({PartyModel? party}) {
    showDialog(
      context: context,
      builder: (context) => PartyFormDialog(party: party),
    ).then((_) => _loadParties());
  }

  void _deleteParty(PartyModel party) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Party'),
        content: Text('Are you sure you want to delete ${party.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final partyProvider =
                  Provider.of<PartyProvider>(context, listen: false);
              final success = await partyProvider.deleteParty(party.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Party deleted successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
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
    final orgProvider = Provider.of<OrganizationProvider>(context);

    if (orgProvider.selectedOrganization == null) {
      return const Center(
        child: Text('Please select an organization first'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Parties', style: AppTextStyles.h1),
                  const SizedBox(height: 8),
                  Text(
                    'Manage customers and vendors for ${orgProvider.selectedOrganization!.name}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showPartyDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add Party'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: AppColors.textLight,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Parties List
          Expanded(
            child: Consumer<PartyProvider>(
              builder: (context, partyProvider, _) {
                if (partyProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (partyProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 64, color: AppColors.warning),
                        const SizedBox(height: 16),
                        Text('Error: ${partyProvider.error}',
                            style: AppTextStyles.bodyLarge
                                .copyWith(color: AppColors.warning)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadParties,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (partyProvider.parties.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outlined,
                            size: 64, color: AppColors.textSecondary),
                        const SizedBox(height: 16),
                        Text('No parties yet',
                            style: AppTextStyles.h2
                                .copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        Text('Add your first customer or vendor',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.textSecondary)),
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
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('Contact Person')),
                        DataColumn(label: Text('Phone')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('GST No')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: partyProvider.parties.map((party) {
                        return DataRow(cells: [
                          DataCell(Text(party.name)),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: party.partyType == 'customer'
                                    ? AppColors.success.withOpacity(0.1)
                                    : party.partyType == 'vendor'
                                        ? AppColors.info.withOpacity(0.1)
                                        : AppColors.warning.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                party.partyTypeLabel,
                                style: TextStyle(
                                  color: party.partyType == 'customer'
                                      ? AppColors.success
                                      : party.partyType == 'vendor'
                                          ? AppColors.info
                                          : AppColors.warning,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text(party.contactPerson ?? '-')),
                          DataCell(Text(party.phone)),
                          DataCell(Text(party.email ?? '-')),
                          DataCell(Text(party.gstNo ?? '-')),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: party.isActive
                                    ? AppColors.success.withOpacity(0.1)
                                    : AppColors.textSecondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                party.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  color: party.isActive
                                      ? AppColors.success
                                      : AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon:
                                      const Icon(Icons.edit_outlined, size: 20),
                                  onPressed: () =>
                                      _showPartyDialog(party: party),
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      size: 20, color: AppColors.warning),
                                  onPressed: () => _deleteParty(party),
                                  tooltip: 'Delete',
                                ),
                              ],
                            ),
                          ),
                        ]);
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

// Party Form Dialog
class PartyFormDialog extends StatefulWidget {
  final PartyModel? party;

  const PartyFormDialog({super.key, this.party});

  @override
  State<PartyFormDialog> createState() => _PartyFormDialogState();
}

class _PartyFormDialogState extends State<PartyFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _contactPersonController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _gstController;
  late TextEditingController _billingAddressController;
  late TextEditingController _shippingAddressController;
  String _partyType = 'customer';
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.party?.name ?? '');
    _contactPersonController =
        TextEditingController(text: widget.party?.contactPerson ?? '');
    _emailController = TextEditingController(text: widget.party?.email ?? '');
    _phoneController = TextEditingController(text: widget.party?.phone ?? '');
    _gstController = TextEditingController(text: widget.party?.gstNo ?? '');
    _billingAddressController =
        TextEditingController(text: widget.party?.billingAddress ?? '');
    _shippingAddressController =
        TextEditingController(text: widget.party?.shippingAddress ?? '');
    _partyType = widget.party?.partyType ?? 'customer';
    _isActive = widget.party?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactPersonController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _gstController.dispose();
    _billingAddressController.dispose();
    _shippingAddressController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final orgProvider =
          Provider.of<OrganizationProvider>(context, listen: false);
      final partyProvider = Provider.of<PartyProvider>(context, listen: false);

      final partyData = {
        'organization_id': orgProvider.selectedOrganization!.id,
        'name': _nameController.text.trim(),
        'contact_person': _contactPersonController.text.trim().isEmpty
            ? null
            : _contactPersonController.text.trim(),
        'email': _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'gst_no': _gstController.text.trim().isEmpty
            ? null
            : _gstController.text.trim(),
        'billing_address': _billingAddressController.text.trim().isEmpty
            ? null
            : _billingAddressController.text.trim(),
        'shipping_address': _shippingAddressController.text.trim().isEmpty
            ? null
            : _shippingAddressController.text.trim(),
        'party_type': _partyType,
        'is_active': _isActive,
      };

      bool success;
      if (widget.party == null) {
        success = await partyProvider.createParty(partyData);
      } else {
        success = await partyProvider.updateParty(widget.party!.id, partyData);
      }

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.party == null
                ? 'Party created successfully'
                : 'Party updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(partyProvider.error ?? 'Operation failed'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.party == null ? 'Add Party' : 'Edit Party',
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Party Name *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _partyType,
                        decoration: const InputDecoration(
                          labelText: 'Party Type *',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'customer', child: Text('Customer')),
                          DropdownMenuItem(
                              value: 'vendor', child: Text('Vendor')),
                          DropdownMenuItem(value: 'both', child: Text('Both')),
                        ],
                        onChanged: (value) =>
                            setState(() => _partyType = value!),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contactPersonController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Person',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              !value.contains('@')) {
                            return 'Invalid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _gstController,
                        decoration: const InputDecoration(
                          labelText: 'GST Number',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _billingAddressController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Billing Address',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _shippingAddressController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Shipping Address',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Active'),
                        value: _isActive,
                        onChanged: (value) => setState(() => _isActive = value),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  Consumer<PartyProvider>(
                    builder: (context, partyProvider, _) {
                      return ElevatedButton(
                        onPressed:
                            partyProvider.isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          foregroundColor: AppColors.textLight,
                        ),
                        child: partyProvider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(widget.party == null ? 'Create' : 'Update'),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
