import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/currency_cubit.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../cubit/budget_cubit.dart';

/// Shows budget warnings on the home screen
/// Only displays budgets that are above 70% used or over budget
class BudgetAlertCard extends StatelessWidget {
  const BudgetAlertCard({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<CurrencyCubit>(); // rebuild when currency changes
    return BlocBuilder<BudgetCubit, BudgetState>(
      builder: (context, state) {
        return state.maybeWhen(
          loaded: (budgets, totalMonthlyBudget, totalSpentThisMonth) {
            // Warning: >= 70% used, Critical: over budget
            final alertBudgets =
                budgets
                    .where((b) => b.percentage >= 70 || b.isOverBudget)
                    .toList()
                  // Most severe (over-budget, then highest %) shown first
                  ..sort((a, b) {
                    if (a.isOverBudget != b.isOverBudget) {
                      return a.isOverBudget ? -1 : 1;
                    }
                    return b.percentage.compareTo(a.percentage);
                  });

            if (alertBudgets.isEmpty) return const SizedBox();

            final overCount = alertBudgets.where((b) => b.isOverBudget).length;

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Budget Alerts',
                                  style: AppTextStyles.sectionTitle,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  overCount > 0
                                      ? '$overCount over budget · ${alertBudgets.length - overCount} nearing limit'
                                      : '${alertBudgets.length} nearing limit',
                                  style: AppTextStyles.bodySecondary.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Alert items ─────────────────────
                    ...alertBudgets.asMap().entries.map((entry) {
                      final isLast = entry.key == alertBudgets.length - 1;
                      return Column(
                        children: [
                          _BudgetAlertItem(item: entry.value),
                          if (!isLast)
                            Divider(
                              height: 1,
                              indent: 20,
                              endIndent: 20,
                              color: Theme.of(context).dividerColor,
                            ),
                        ],
                      );
                    }),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
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
    context.watch<CurrencyCubit>(); // rebuild when currency changes
    final color = Color(item.categoryColorValue);
    final isOverBudget = item.isOverBudget;
    final alertColor = isOverBudget ? AppColors.expense : AppColors.warning;
    // Cap the visual bar at 100% even if spend has gone further over
    final progress = (item.percentage / 100).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.categoryIcon, color: color, size: 18),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.categoryName,
                        style: AppTextStyles.cardTitle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: alertColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isOverBudget
                            ? 'Over budget'
                            : '${item.percentage.toStringAsFixed(0)}%',
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Theme.of(context).dividerColor,
                    valueColor: AlwaysStoppedAnimation<Color>(alertColor),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${CurrencyFormatter.format(item.spent)} spent',
                      style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
                    ),
                    Text(
                      'of ${CurrencyFormatter.format(item.budget.amount)}',
                      style: AppTextStyles.bodySecondary.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
