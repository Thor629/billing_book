import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/fintech_button.dart';
import '../../widgets/fintech_card.dart';

/// Demo screen showing warm theme color scheme implementation
class FintechDemoScreen extends StatelessWidget {
  const FintechDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Warm Theme Demo'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            FintechBalanceCard(
              title: 'Total Balance',
              amount: '16,008.00',
              currency: 'USD',
              actions: [
                WarmButton(
                  text: 'Top up',
                  icon: Icons.add,
                  style: WarmButtonStyle.peach,
                  width: 120,
                  onPressed: () {},
                ),
                WarmButton(
                  text: 'Transfer',
                  icon: Icons.swap_horiz,
                  style: WarmButtonStyle.green,
                  width: 120,
                  onPressed: () {},
                ),
                WarmButton(
                  text: 'Withdraw',
                  icon: Icons.account_balance_wallet,
                  style: WarmButtonStyle.blue,
                  width: 120,
                  onPressed: () {},
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Services Section
            FintechCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Services',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1,
                    children: [
                      WarmIconButton(
                        icon: Icons.add,
                        label: 'Add new',
                        style: WarmButtonStyle.peach,
                        onPressed: () {},
                      ),
                      WarmIconButton(
                        icon: Icons.people,
                        label: 'Family',
                        style: WarmButtonStyle.green,
                        onPressed: () {},
                      ),
                      WarmIconButton(
                        icon: Icons.person,
                        label: 'Friend',
                        style: WarmButtonStyle.blue,
                        onPressed: () {},
                      ),
                      WarmIconButton(
                        icon: Icons.business,
                        label: 'Company',
                        style: WarmButtonStyle.orange,
                        onPressed: () {},
                      ),
                      WarmIconButton(
                        icon: Icons.coffee,
                        label: 'Coffee',
                        style: WarmButtonStyle.pink,
                        onPressed: () {},
                      ),
                      WarmIconButton(
                        icon: Icons.shopping_bag,
                        label: 'Shopping',
                        style: WarmButtonStyle.coral,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Spending Section
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            FintechAccentCard(
              accentColor: AppColors.warmPeach,
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lewis Baldwin',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '09 Dec 2020',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    '+ \$1,220.00',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            FintechAccentCard(
              accentColor: AppColors.warmOrange,
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.train),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Metro Ticket',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '08 Dec 2020',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    '- \$0.00',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Button Examples
            const Text(
              'Button Styles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            FintechCard(
              child: Column(
                children: [
                  WarmButton(
                    text: 'Peach Button (Primary)',
                    icon: Icons.add,
                    style: WarmButtonStyle.peach,
                    width: double.infinity,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 12),
                  WarmButton(
                    text: 'Orange Button (Action)',
                    icon: Icons.flash_on,
                    style: WarmButtonStyle.orange,
                    width: double.infinity,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 12),
                  WarmButton(
                    text: 'Pink Button (Accent)',
                    icon: Icons.favorite,
                    style: WarmButtonStyle.pink,
                    width: double.infinity,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 12),
                  WarmButton(
                    text: 'Green Button (Success)',
                    icon: Icons.check,
                    style: WarmButtonStyle.green,
                    width: double.infinity,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 12),
                  WarmButton(
                    text: 'Blue Button (Info)',
                    icon: Icons.info,
                    style: WarmButtonStyle.blue,
                    width: double.infinity,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 12),
                  WarmButton(
                    text: 'Dark Button (Critical)',
                    icon: Icons.delete,
                    style: WarmButtonStyle.dark,
                    width: double.infinity,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
