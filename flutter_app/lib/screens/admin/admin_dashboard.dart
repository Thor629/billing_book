import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import 'user_management_screen.dart';
import 'plan_management_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentScreen = 0;

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
                          Icons.business,
                          color: AppColors.textLight,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'SaaS Billing',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                      Text(
                        'Admin Panel',
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
                          icon: Icons.people_outlined,
                          label: 'Users',
                          isActive: _currentScreen == 1,
                          onTap: () => setState(() => _currentScreen = 1),
                        ),
                        _buildMenuItem(
                          icon: Icons.card_membership_outlined,
                          label: 'Plans',
                          isActive: _currentScreen == 2,
                          onTap: () => setState(() => _currentScreen = 2),
                        ),
                        _buildMenuItem(
                          icon: Icons.bar_chart_outlined,
                          label: 'Reports',
                        ),
                        _buildMenuItem(
                          icon: Icons.settings_outlined,
                          label: 'Settings',
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
                    onTap: () => authProvider.logout(),
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: _currentScreen == 0
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Admin Dashboard', style: AppTextStyles.h1),
                        const SizedBox(height: 8),
                        Text(
                          'Welcome back, ${authProvider.user?.name ?? "Admin"}!',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Metrics Cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                'Total Users',
                                '1,234',
                                Icons.people,
                                AppColors.info,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildMetricCard(
                                'Active Subscriptions',
                                '856',
                                Icons.card_membership,
                                AppColors.success,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildMetricCard(
                                'Revenue',
                                '\$12,345',
                                Icons.attach_money,
                                AppColors.warning,
                              ),
                            ),
                          ],
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
                  )
                : _currentScreen == 1
                    ? const UserManagementScreen()
                    : const PlanManagementScreen(),
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

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: AppTextStyles.bodyMedium),
                Icon(icon, color: color),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: AppTextStyles.h1),
          ],
        ),
      ),
    );
  }
}
