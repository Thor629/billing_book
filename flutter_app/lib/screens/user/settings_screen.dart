import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/organization_provider.dart';
import '../../core/constants/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final orgProvider = Provider.of<OrganizationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // User Info Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'User Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryDark,
                    child: Text(
                      authProvider.user?.name.substring(0, 1).toUpperCase() ??
                          'U',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(authProvider.user?.name ?? 'User'),
                  subtitle: Text(authProvider.user?.email ?? ''),
                ),
              ],
            ),
          ),

          // Organization Section
          const SizedBox(height: 8),
          _buildSectionHeader('Organization'),
          _buildSettingsTile(
            icon: Icons.business,
            title: 'Current Organization',
            subtitle: orgProvider.selectedOrganization?.name ??
                'No organization selected',
            onTap: () {
              // Navigate to organization selection
            },
          ),

          // App Settings Section
          const SizedBox(height: 8),
          _buildSectionHeader('App Settings'),
          _buildSettingsTile(
            icon: Icons.receipt_long,
            title: 'Invoice Settings',
            subtitle: 'Configure invoice templates and numbering',
            onTap: () {
              _showComingSoonDialog('Invoice Settings');
            },
          ),
          _buildSettingsTile(
            icon: Icons.payment,
            title: 'Payment Settings',
            subtitle: 'Configure payment methods and terms',
            onTap: () {
              _showComingSoonDialog('Payment Settings');
            },
          ),
          _buildSettingsTile(
            icon: Icons.calculate,
            title: 'Tax Settings',
            subtitle: 'Configure tax rates and GST',
            onTap: () {
              _showComingSoonDialog('Tax Settings');
            },
          ),
          _buildSettingsTile(
            icon: Icons.print,
            title: 'Print Settings',
            subtitle: 'Configure print templates',
            onTap: () {
              _showComingSoonDialog('Print Settings');
            },
          ),

          // Data Management Section
          const SizedBox(height: 8),
          _buildSectionHeader('Data Management'),
          _buildSettingsTile(
            icon: Icons.backup,
            title: 'Backup & Restore',
            subtitle: 'Backup your data',
            onTap: () {
              _showComingSoonDialog('Backup & Restore');
            },
          ),
          _buildSettingsTile(
            icon: Icons.download,
            title: 'Export Data',
            subtitle: 'Export to Excel or PDF',
            onTap: () {
              _showComingSoonDialog('Export Data');
            },
          ),

          // Account Section
          const SizedBox(height: 8),
          _buildSectionHeader('Account'),
          _buildSettingsTile(
            icon: Icons.person,
            title: 'Profile',
            subtitle: 'Edit your profile information',
            onTap: () {
              _showComingSoonDialog('Profile');
            },
          ),
          _buildSettingsTile(
            icon: Icons.lock,
            title: 'Change Password',
            subtitle: 'Update your password',
            onTap: () {
              _showComingSoonDialog('Change Password');
            },
          ),
          _buildSettingsTile(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Manage notification preferences',
            onTap: () {
              _showComingSoonDialog('Notifications');
            },
          ),

          // About Section
          const SizedBox(height: 8),
          _buildSectionHeader('About'),
          _buildSettingsTile(
            icon: Icons.info,
            title: 'About App',
            subtitle: 'Version 1.0.0',
            onTap: () {
              _showAboutDialog();
            },
          ),
          _buildSettingsTile(
            icon: Icons.help,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () {
              _showComingSoonDialog('Help & Support');
            },
          ),
          _buildSettingsTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            onTap: () {
              _showComingSoonDialog('Privacy Policy');
            },
          ),

          // Logout
          const SizedBox(height: 8),
          _buildSettingsTile(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            textColor: Colors.red,
            onTap: () {
              _showLogoutDialog();
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.primaryDark),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: Text('$feature feature will be available in the next update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Billing SaaS'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text(
                'A comprehensive billing and invoicing solution for businesses.'),
            SizedBox(height: 16),
            Text('© 2025 Billing SaaS Platform'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              if (mounted) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
