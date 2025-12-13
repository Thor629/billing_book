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
import 'sales_invoices_screen.dart';
import 'quotations_screen.dart';
import 'payment_in_screen.dart';
import 'sales_return_screen.dart';
import 'credit_note_screen.dart';
import 'purchase_invoices_screen.dart';
import 'cash_bank_screen.dart';
import 'expenses_screen.dart';
import 'delivery_challan_screen.dart';
import 'payment_out_screen.dart';
import 'purchase_return_screen.dart';
import 'debit_note_screen.dart';
import 'gst_report_screen.dart';
import 'pos_billing_screen.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _currentScreen = 0;
  bool _itemsMenuExpanded = false;
  bool _salesMenuExpanded = false;
  bool _purchasesMenuExpanded = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Sidebar - Soft Blue Theme
          Container(
            width: 260,
            decoration: BoxDecoration(
              color: AppColors.sidebarBackground,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 15,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Logo/Header - Warm Orange Gradient
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFFB347), // Warm orange
                        Color(0xFFFFCC80), // Light orange
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            color: Color(0xFFFF9F43),
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        authProvider.user?.name ?? 'User',
                        style: AppTextStyles.h4.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        authProvider.user?.email ?? '',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

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
                        // Expandable Sales Menu
                        _buildExpandableMenuItem(
                          icon: Icons.receipt_long_outlined,
                          label: 'Sales',
                          isExpanded: _salesMenuExpanded,
                          onTap: () => setState(
                              () => _salesMenuExpanded = !_salesMenuExpanded),
                          children: [
                            _buildSubMenuItem(
                              label: 'Quotation / Estimate',
                              isActive: _currentScreen == 7,
                              onTap: () => setState(() {
                                _currentScreen = 7;
                                _salesMenuExpanded = true;
                              }),
                            ),
                            _buildSubMenuItem(
                              label: 'Sales Invoices',
                              isActive: _currentScreen == 8,
                              onTap: () => setState(() {
                                _currentScreen = 8;
                                _salesMenuExpanded = true;
                              }),
                            ),
                            _buildSubMenuItem(
                              label: 'Payment In',
                              isActive: _currentScreen == 9,
                              onTap: () => setState(() {
                                _currentScreen = 9;
                                _salesMenuExpanded = true;
                              }),
                            ),
                            _buildSubMenuItem(
                              label: 'Sales Return',
                              isActive: _currentScreen == 10,
                              onTap: () => setState(() {
                                _currentScreen = 10;
                                _salesMenuExpanded = true;
                              }),
                            ),
                            _buildSubMenuItem(
                              label: 'Credit Note',
                              isActive: _currentScreen == 11,
                              onTap: () => setState(() {
                                _currentScreen = 11;
                                _salesMenuExpanded = true;
                              }),
                            ),
                            _buildSubMenuItem(
                              label: 'Delivery Challan',
                              isActive: _currentScreen == 12,
                              onTap: () => setState(() {
                                _currentScreen = 12;
                                _salesMenuExpanded = true;
                              }),
                            ),
                            _buildSubMenuItem(
                              label: 'Proforma Invoice',
                              isActive: _currentScreen == 13,
                              onTap: () => setState(() {
                                _currentScreen = 13;
                                _salesMenuExpanded = true;
                              }),
                            ),
                          ],
                        ),
                        // Expandable Purchases Menu
                        _buildExpandableMenuItem(
                          icon: Icons.shopping_bag_outlined,
                          label: 'Purchases',
                          isExpanded: _purchasesMenuExpanded,
                          onTap: () => setState(() =>
                              _purchasesMenuExpanded = !_purchasesMenuExpanded),
                          children: [
                            _buildSubMenuItem(
                              label: 'Purchase Invoices',
                              isActive: _currentScreen == 14,
                              onTap: () => setState(() {
                                _currentScreen = 14;
                                _purchasesMenuExpanded = true;
                              }),
                            ),
                            _buildSubMenuItem(
                              label: 'Payment Out',
                              isActive: _currentScreen == 15,
                              onTap: () => setState(() {
                                _currentScreen = 15;
                                _purchasesMenuExpanded = true;
                              }),
                            ),
                            _buildSubMenuItem(
                              label: 'Purchase Return',
                              isActive: _currentScreen == 16,
                              onTap: () => setState(() {
                                _currentScreen = 16;
                                _purchasesMenuExpanded = true;
                              }),
                            ),
                            _buildSubMenuItem(
                              label: 'Debit Note',
                              isActive: _currentScreen == 17,
                              onTap: () => setState(() {
                                _currentScreen = 17;
                                _purchasesMenuExpanded = true;
                              }),
                            ),
                            _buildSubMenuItem(
                              label: 'Purchase Orders',
                              isActive: _currentScreen == 18,
                              onTap: () => setState(() {
                                _currentScreen = 18;
                                _purchasesMenuExpanded = true;
                              }),
                            ),
                          ],
                        ),

                        // Section Header - Accounting Solutions
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                          child: Text(
                            'ACCOUNTING SOLUTIONS',
                            style: AppTextStyles.overline.copyWith(
                              color: AppColors.sidebarTextMuted,
                            ),
                          ),
                        ),

                        // Cash & Bank Menu Item
                        _buildMenuItem(
                          icon: Icons.account_balance_outlined,
                          label: 'Cash & Bank',
                          isActive: _currentScreen == 19,
                          onTap: () => setState(() => _currentScreen = 19),
                        ),
                        _buildMenuItem(
                          icon: Icons.assessment_outlined,
                          label: 'GST Report',
                          isActive: _currentScreen == 20,
                          onTap: () => setState(() => _currentScreen = 20),
                        ),
                        _buildMenuItem(
                          icon: Icons.receipt_outlined,
                          label: 'E-Invoicing',
                          isActive: _currentScreen == 22,
                          onTap: () => setState(() => _currentScreen = 22),
                        ),
                        _buildMenuItem(
                          icon: Icons.description_outlined,
                          label: 'Automated Bills',
                          isActive: _currentScreen == 23,
                          onTap: () => setState(() => _currentScreen = 23),
                        ),
                        _buildMenuItem(
                          icon: Icons.wallet_outlined,
                          label: 'Expenses',
                          isActive: _currentScreen == 24,
                          onTap: () => setState(() => _currentScreen = 24),
                        ),
                        _buildMenuItem(
                          icon: Icons.point_of_sale_outlined,
                          label: 'POS Billing',
                          isActive: _currentScreen == 21,
                          onTap: () => setState(() => _currentScreen = 21),
                        ),

                        // Section Header - Business Tools
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                          child: Text(
                            'BUSINESS TOOLS',
                            style: AppTextStyles.overline.copyWith(
                              color: AppColors.sidebarTextMuted,
                            ),
                          ),
                        ),

                        _buildMenuItem(
                          icon: Icons.calendar_today_outlined,
                          label: 'Staff Attendance & Payroll',
                          isActive: _currentScreen == 26,
                          onTap: () => setState(() => _currentScreen = 26),
                        ),
                        _buildMenuItem(
                          icon: Icons.manage_accounts_outlined,
                          label: 'Manage Users',
                          isActive: _currentScreen == 27,
                          onTap: () => setState(() => _currentScreen = 27),
                        ),
                        _buildMenuItem(
                          icon: Icons.shopping_cart_outlined,
                          label: 'Online Orders',
                          isActive: _currentScreen == 28,
                          onTap: () => setState(() => _currentScreen = 28),
                        ),
                        _buildMenuItem(
                          icon: Icons.sms_outlined,
                          label: 'SMS Marketing',
                          isActive: _currentScreen == 29,
                          onTap: () => setState(() => _currentScreen = 29),
                        ),
                        _buildMenuItem(
                          icon: Icons.request_quote_outlined,
                          label: 'Apply For Loan',
                          isActive: _currentScreen == 30,
                          onTap: () => setState(() => _currentScreen = 30),
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
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.3),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          // Clear organization data on logout
                          await Provider.of<OrganizationProvider>(context,
                                  listen: false)
                              .clearOrganization();
                          await authProvider.logout();
                        },
                        borderRadius: BorderRadius.circular(12),
                        hoverColor: AppColors.error.withOpacity(0.2),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.logout_rounded,
                                color: AppColors.error,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Logout',
                                style: AppTextStyles.buttonMedium.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
      case 7:
        return const QuotationsScreen();
      case 8:
        return const SalesInvoicesScreen();
      case 9:
        return const PaymentInScreen();
      case 10:
        return const SalesReturnScreen();
      case 11:
        return const CreditNoteScreen();
      case 12:
        return const DeliveryChallanScreen();
      case 13:
        return _buildPlaceholderScreen('Proforma Invoice');
      case 14:
        return const PurchaseInvoicesScreen();
      case 15:
        return const PaymentOutScreen();
      case 16:
        return const PurchaseReturnScreen();
      case 17:
        return const DebitNoteScreen();
      case 18:
        return _buildPlaceholderScreen('Purchase Orders');
      // Accounting Solutions
      case 19:
        return const CashBankScreen();
      case 20:
        return const GstReportScreen();
      case 21:
        return const PosBillingScreen();
      case 22:
        return _buildPlaceholderScreen('E-Invoicing');
      case 23:
        return _buildPlaceholderScreen('Automated Bills');
      case 24:
        return const ExpensesScreen();
      // Business Tools
      case 26:
        return _buildPlaceholderScreen('Staff Attendance & Payroll');
      case 27:
        return _buildPlaceholderScreen('Manage Users');
      case 28:
        return _buildPlaceholderScreen('Online Orders');
      case 29:
        return _buildPlaceholderScreen('SMS Marketing');
      case 30:
        return _buildPlaceholderScreen('Apply For Loan');
      default:
        return _buildDashboard();
    }
  }

  Widget _buildPlaceholderScreen(String title) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h1),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.construction_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$title - Coming Soon',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This feature is under development',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? AppColors.sidebarActiveLight : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isActive
            ? Border.all(color: AppColors.sidebarActiveOrange, width: 1.5)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          hoverColor: AppColors.sidebarHover,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive
                      ? AppColors.sidebarActiveOrange
                      : AppColors.sidebarText,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.menuItem.copyWith(
                      color: isActive
                          ? AppColors.sidebarActiveOrange
                          : AppColors.sidebarText,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.sidebarActiveOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
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
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isExpanded ? AppColors.sidebarHover : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              hoverColor: AppColors.sidebarHover,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: AppColors.sidebarText,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.sidebarText,
                          fontWeight:
                              isExpanded ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.sidebarText,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child:
              isExpanded ? Column(children: children) : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildSubMenuItem({
    required String label,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(left: 24, right: 8, top: 2, bottom: 2),
      decoration: BoxDecoration(
        color: isActive ? AppColors.sidebarActiveLight : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isActive
            ? Border.all(color: AppColors.sidebarActiveOrange, width: 1)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          hoverColor: AppColors.sidebarHover,
          child: Padding(
            padding:
                const EdgeInsets.only(left: 48, right: 16, top: 10, bottom: 10),
            child: Row(
              children: [
                if (isActive)
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: const BoxDecoration(
                      color: AppColors.sidebarActiveOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isActive
                          ? AppColors.sidebarActiveOrange
                          : AppColors.sidebarText,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
