import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../cubit/budget_cubit.dart';

/// Shows budget warnings on the home screen
/// Only displays budgets that are above 70% used or over budget
class BudgetAlertCard extends StatelessWidget {
  const BudgetAlertCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BudgetCubit, BudgetState>(
      builder: (context, state) {
        return state.maybeWhen(
          loaded: (budgets) {
            // Only show budgets that need attention
            // Warning: >= 70% used
            // Critical: over budget
            final alertBudgets = budgets
                .where((b) => b.percentage >= 70 || b.isOverBudget)
                .toList();

            // No alerts — show nothing
            if (alertBudgets.isEmpty) return const SizedBox();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Budget Alerts',
                        style: AppTextStyles.sectionTitle,
                      ),
                      const Spacer(),
                      // Show count badge if multiple alerts
                      if (alertBudgets.length > 1)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.expense.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${alertBudgets.length}',
                            style: const TextStyle(
                              color: AppColors.expense,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Show each alert budget
                ...alertBudgets.map((item) => _BudgetAlertItem(item: item)),
              ],
            );
          },
          orElse: () => const SizedBox(),
        );
      },
    );
  }
}

class _BudgetAlertItem extends StatelessWidget {
  final BudgetWithProgress item;

  const _BudgetAlertItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = Color(item.categoryColorValue);

    // Determine alert level
    final isOverBudget = item.isOverBudget;
    final alertColor = isOverBudget ? AppColors.expense : AppColors.warning;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          // Colored left border indicates severity
          border: Border(left: BorderSide(color: alertColor, width: 4)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Category icon
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(item.categoryIcon, color: color, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.categoryName,
                    style: AppTextStyles.cardTitle,
                  ),
                ),
                // Alert badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: alertColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isOverBudget
                        ? 'Over budget!'
                        : '${item.percentage.toStringAsFixed(0)}% used',
                    style: TextStyle(
                      color: alertColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: item.percentage / 100,
                backgroundColor: Theme.of(context).dividerColor,
                valueColor: AlwaysStoppedAnimation<Color>(alertColor),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            // Spent vs limit
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${CurrencyFormatter.format(item.spent)} spent',
                  style: AppTextStyles.bodySecondary,
                ),
                Text(
                  'of ${CurrencyFormatter.format(item.budget.amount)}',
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
