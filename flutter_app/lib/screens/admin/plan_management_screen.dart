import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/plan_model.dart';
import '../../services/plan_service.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/custom_button.dart';

class PlanManagementScreen extends StatefulWidget {
  const PlanManagementScreen({super.key});

  @override
  State<PlanManagementScreen> createState() => _PlanManagementScreenState();
}

class _PlanManagementScreenState extends State<PlanManagementScreen> {
  final PlanService _planService = PlanService();
  List<PlanModel> _plans = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final plans = await _planService.getPlans(adminView: true);
      setState(() {
        _plans = plans;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _showPlanDialog({PlanModel? plan}) {
    final nameController = TextEditingController(text: plan?.name);
    final descController = TextEditingController(text: plan?.description);
    final priceMonthlyController = TextEditingController(
      text: plan?.priceMonthly.toString(),
    );
    final priceYearlyController = TextEditingController(
      text: plan?.priceYearly.toString(),
    );
    final featuresController = TextEditingController(
      text: plan?.features.join('\n'),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          plan == null ? 'Add New Plan' : 'Edit Plan',
          style: AppTextStyles.h2,
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Plan Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceMonthlyController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Monthly Price',
                          prefixText: '\$',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: priceYearlyController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Yearly Price',
                          prefixText: '\$',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: featuresController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Features (one per line)',
                    border: OutlineInputBorder(),
                    hintText: 'Feature 1\nFeature 2\nFeature 3',
                  ),
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
          CustomButton(
            text: plan == null ? 'Create' : 'Update',
            onPressed: () async {
              try {
                final planData = {
                  'name': nameController.text,
                  'description': descController.text,
                  'price_monthly': double.parse(priceMonthlyController.text),
                  'price_yearly': double.parse(priceYearlyController.text),
                  'features': featuresController.text
                      .split('\n')
                      .where((f) => f.trim().isNotEmpty)
                      .toList(),
                };

                if (plan == null) {
                  await _planService.createPlan(planData);
                } else {
                  await _planService.updatePlan(plan.id, planData);
                }

                if (mounted) {
                  Navigator.pop(context);
                  _loadPlans();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        plan == null
                            ? 'Plan created successfully'
                            : 'Plan updated successfully',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deletePlan(PlanModel plan) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${plan.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.warning),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _planService.deletePlan(plan.id);
        _loadPlans();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Plan deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Plan Management', style: AppTextStyles.h1),
                    const SizedBox(height: 8),
                    Text(
                      'Manage subscription plans and pricing',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                CustomButton(
                  text: 'Add Plan',
                  icon: Icons.add,
                  onPressed: () => _showPlanDialog(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Plans Grid
            Expanded(
              child: _isLoading
                  ? const LoadingIndicator()
                  : _error != null
                      ? Center(child: Text(_error!))
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: _plans.length,
                          itemBuilder: (context, index) {
                            final plan = _plans[index];
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(plan.name,
                                            style: AppTextStyles.h2),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.edit_outlined),
                                              onPressed: () =>
                                                  _showPlanDialog(plan: plan),
                                              tooltip: 'Edit',
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: AppColors.warning,
                                              ),
                                              onPressed: () =>
                                                  _deletePlan(plan),
                                              tooltip: 'Delete',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (plan.description != null)
                                      Text(
                                        plan.description!,
                                        style: AppTextStyles.bodySmall,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    const SizedBox(height: 16),
                                    Text(
                                      '\$${plan.priceMonthly}/month',
                                      style: AppTextStyles.h3,
                                    ),
                                    Text(
                                      '\$${plan.priceYearly}/year',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Divider(),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: plan.features.length,
                                        itemBuilder: (context, i) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.check_circle_outline,
                                                  size: 16,
                                                  color: AppColors.success,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    plan.features[i],
                                                    style:
                                                        AppTextStyles.bodySmall,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
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
