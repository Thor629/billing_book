import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../models/party_model.dart';
import '../providers/auth_provider.dart';
import '../providers/organization_provider.dart';
import '../services/party_service.dart';
import 'loading_indicator.dart';

class PartySelectionDialog extends StatefulWidget {
  final Function(PartyModel) onPartySelected;

  const PartySelectionDialog({
    super.key,
    required this.onPartySelected,
  });

  @override
  State<PartySelectionDialog> createState() => _PartySelectionDialogState();
}

class _PartySelectionDialogState extends State<PartySelectionDialog> {
  final PartyService _partyService = PartyService();
  final TextEditingController _searchController = TextEditingController();

  List<PartyModel> _parties = [];
  List<PartyModel> _filteredParties = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadParties();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterParties();
    });
  }

  Future<void> _loadParties() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final orgProvider =
          Provider.of<OrganizationProvider>(context, listen: false);

      final token = await authProvider.token;
      if (token == null) throw Exception('Not authenticated');

      final organizationId = orgProvider.selectedOrganization?.id;
      if (organizationId == null) throw Exception('No organization selected');

      final parties = await _partyService.getParties(organizationId);

      setState(() {
        _parties = parties;
        _filteredParties = parties;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading parties: $e')),
        );
      }
    }
  }

  void _filterParties() {
    if (_searchQuery.isEmpty) {
      setState(() {
        _filteredParties = _parties;
      });
      return;
    }

    final query = _searchQuery.toLowerCase();
    setState(() {
      _filteredParties = _parties.where((party) {
        return party.name.toLowerCase().contains(query) ||
            (party.phone.toLowerCase().contains(query)) ||
            (party.gstNo?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  void _selectParty(PartyModel party) {
    widget.onPartySelected(party);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        height: 600,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.people,
                      color: AppColors.primaryDark,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Select Party',
                    style: AppTextStyles.h2,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name, phone, or GST number',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
            ),

            // Party List
            Expanded(
              child: _isLoading
                  ? const Center(child: LoadingIndicator())
                  : _filteredParties.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty
                                    ? 'No parties found'
                                    : 'No results for "$_searchQuery"',
                                style: AppTextStyles.h3.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () {
                                  // TODO: Navigate to create party screen
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Create New Party'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredParties.length,
                          itemBuilder: (context, index) {
                            final party = _filteredParties[index];
                            return InkWell(
                              onTap: () => _selectParty(party),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryDark
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          party.name[0].toUpperCase(),
                                          style: AppTextStyles.h3.copyWith(
                                            color: AppColors.primaryDark,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            party.name,
                                            style: AppTextStyles.bodyMedium
                                                .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            party.phone,
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          if (party.gstNo != null)
                                            Text(
                                              'GST: ${party.gstNo}',
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.grey.shade400,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
