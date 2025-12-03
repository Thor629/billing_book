import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/organization_provider.dart';
import 'profile_screen.dart';
import 'plans_screen.dart';
import 'organizations_screen.dart';
import 'parties_screen.dart';
import 'items_screen_enhanced.dart';
import 'godowns_screen.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _currentScreen = 0;
  bool _itemsMenuExpanded = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 240,
            color: AppColors.primaryDark,
            child: Column(
              children: [
                // Logo/Header
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.primaryLight,
                        child: Icon(
                          Icons.person,
                          color: AppColors.textLight,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        authProvider.user?.name ?? 'User',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                      Text(
                        authProvider.user?.email ?? '',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textLight.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.primaryLight),

                // Menu Items - Scrollable
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildMenuItem(
                          icon: Icons.dashboard_outlined,
                          label: 'Dashboard',
                          isActive: _currentScreen == 0,
                          onTap: () => setState(() => _currentScreen = 0),
                        ),
                        _buildMenuItem(
                          icon: Icons.business_outlined,
                          label: 'Organizations',
                          isActive: _currentScreen == 1,
                          onTap: () => setState(() => _currentScreen = 1),
                        ),
                        _buildMenuItem(
                          icon: Icons.people_outlined,
                          label: 'Parties',
                          isActive: _currentScreen == 2,
                          onTap: () => setState(() => _currentScreen = 2),
                        ),
                        // Expandable Items Menu
                        _buildExpandableMenuItem(
                          icon: Icons.inventory_2_outlined,
                          label: 'Items',
                          isExpanded: _itemsMenuExpanded,
                          onTap: () => setState(
                              () => _itemsMenuExpanded = !_itemsMenuExpanded),
                          children: [
                            _buildSubMenuItem(
                              label: 'Items',
                              isActive: _currentScreen == 3,
                              onTap: () => setState(() {
                                _currentScreen = 3;
                                _itemsMenuExpanded = true;
                              }),
                            ),
                            _buildSubMenuItem(
                              label: 'Warehouses',
                              isActive: _currentScreen == 4,
                              onTap: () => setState(() {
                                _currentScreen = 4;
                                _itemsMenuExpanded = true;
                              }),
                            ),
                          ],
                        ),
                        _buildMenuItem(
                          icon: Icons.person_outlined,
                          label: 'My Profile',
                          isActive: _currentScreen == 5,
                          onTap: () => setState(() => _currentScreen = 5),
                        ),
                        _buildMenuItem(
                          icon: Icons.card_membership_outlined,
                          label: 'Plans',
                          isActive: _currentScreen == 6,
                          onTap: () => setState(() => _currentScreen = 6),
                        ),
                        _buildMenuItem(
                          icon: Icons.subscriptions_outlined,
                          label: 'Subscription',
                        ),
                        _buildMenuItem(
                          icon: Icons.support_agent_outlined,
                          label: 'Support',
                        ),
                      ],
                    ),
                  ),
                ),

                // Logout
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListTile(
                    leading: const Icon(
                      Icons.logout,
                      color: AppColors.textLight,
                    ),
                    title: Text(
                      'Logout',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                    onTap: () {
                      // Clear organization data on logout
                      Provider.of<OrganizationProvider>(context, listen: false)
                          .clearOrganization();
                      authProvider.logout();
                    },
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: _getScreen(),
          ),
        ],
      ),
    );
  }

  Widget _getScreen() {
    switch (_currentScreen) {
      case 0:
        return _buildDashboard();
      case 1:
        return const OrganizationsScreen();
      case 2:
        return const PartiesScreen();
      case 3:
        return const ItemsScreenEnhanced();
      case 4:
        return const GodownsScreen();
      case 5:
        return const ProfileScreen();
      case 6:
        return const PlansScreen();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    final authProvider = Provider.of<AuthProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard', style: AppTextStyles.h1),
          const SizedBox(height: 8),
          Text(
            'Welcome back, ${authProvider.user?.name ?? "User"}!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Subscription Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.card_membership,
                        color: AppColors.success,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Plan',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text('Pro Plan', style: AppTextStyles.h2),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Your subscription is active and will renew on Dec 31, 2024',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Placeholder for more content
          Expanded(
            child: Card(
              child: Center(
                child: Text(
                  'Dashboard content coming soon...',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryLight : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppColors.textLight,
        ),
        title: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textLight,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildExpandableMenuItem({
    required IconData icon,
    required String label,
    required bool isExpanded,
    required VoidCallback onTap,
    required List<Widget> children,
  }) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: ListTile(
            leading: Icon(
              icon,
              color: AppColors.textLight,
            ),
            title: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textLight,
              ),
            ),
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: AppColors.textLight,
            ),
            onTap: onTap,
          ),
        ),
        if (isExpanded) ...children,
      ],
    );
  }

  Widget _buildSubMenuItem({
    required String label,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 24, right: 8, top: 2, bottom: 2),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryLight : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 48, right: 16),
        title: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textLight,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
