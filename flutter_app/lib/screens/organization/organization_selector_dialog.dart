import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/organization_provider.dart';
import '../../providers/auth_provider.dart';
import 'create_organization_screen.dart';

class OrganizationSelectorDialog extends StatefulWidget {
  const OrganizationSelectorDialog({super.key});

  @override
  State<OrganizationSelectorDialog> createState() =>
      _OrganizationSelectorDialogState();
}

class _OrganizationSelectorDialogState
    extends State<OrganizationSelectorDialog> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrganizations();
    });
  }

  Future<void> _loadOrganizations() async {
    if (_isInitialized) return;
    _isInitialized = true;

    print('OrganizationSelectorDialog: Starting to load organizations');
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);

    print(
        'OrganizationSelectorDialog: Current state - orgs: ${orgProvider.organizations.length}, loading: ${orgProvider.isLoading}');

    // Only load if not already loaded
    if (orgProvider.organizations.isEmpty && !orgProvider.isLoading) {
      print('OrganizationSelectorDialog: Calling loadOrganizations');
      await orgProvider.loadOrganizations();
    }

    if (!mounted) return;

    print(
        'OrganizationSelectorDialog: After load - orgs: ${orgProvider.organizations.length}, hasOrg: ${orgProvider.hasOrganization}');

    // Auto-select if only one organization
    if (orgProvider.organizations.length == 1 && !orgProvider.hasOrganization) {
      print('OrganizationSelectorDialog: Auto-selecting single organization');
      await orgProvider.selectOrganization(orgProvider.organizations.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrganizationProvider>(
      builder: (context, orgProvider, _) {
        if (orgProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If no organizations, show create form
        if (orgProvider.organizations.isEmpty) {
          // Show error if there was one
          if (orgProvider.error != null) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error loading organizations',
                        style: AppTextStyles.h2),
                    const SizedBox(height: 8),
                    Text(orgProvider.error!, style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _isInitialized = false);
                        _loadOrganizations();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          return const CreateOrganizationScreen();
        }

        // If multiple organizations, show selection dialog
        return Scaffold(
          backgroundColor: Colors.black54,
          body: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              margin: const EdgeInsets.all(24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Select Organization',
                        style: AppTextStyles.h1,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose an organization to continue',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Organization list
                      ...orgProvider.organizations.map((org) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primaryDark,
                              child: Text(
                                org.name[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              org.name,
                              style: AppTextStyles.bodyLarge,
                            ),
                            subtitle: Text(
                              org.email,
                              style: AppTextStyles.bodySmall,
                            ),
                            trailing: org.isOwner
                                ? Chip(
                                    label: Text(
                                      'Owner',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: AppColors.success,
                                  )
                                : null,
                            onTap: () {
                              orgProvider.selectOrganization(org);
                            },
                          ),
                        );
                      }).toList(),

                      const SizedBox(height: 16),

                      // Create new organization button
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CreateOrganizationScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Create New Organization'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
}
