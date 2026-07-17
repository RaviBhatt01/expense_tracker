import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/expense.dart';
import '../cubit/category_cubit.dart';

class RecentTransactionsList extends StatelessWidget {
  final List<Expense> expenses;

  const RecentTransactionsList({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Text(
              'No transactions yet.\nTap + to add one!',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final expense = expenses[index];
        final isExpense = expense.type == TransactionType.expense;

        // Look up category from CategoryCubit using categoryId
        final category = context.read<CategoryCubit>().getCategoryById(
          expense.categoryId,
        );

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Real category icon — falls back to default if not found
                _CategoryIcon(category: category),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(expense.title, style: AppTextStyles.cardTitle),
                      const SizedBox(height: 4),
                      // Show category name under title
                      Text(
                        category?.name ?? 'General',
                        style: AppTextStyles.cardSubTitle,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isExpense ? '-' : '+'}${CurrencyFormatter.format(expense.amount)}',
                      style: isExpense
                          ? AppTextStyles.expenseAmount
                          : AppTextStyles.incomeAmount,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormatter.format(expense.date),
                      style: AppTextStyles.bodySecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }, childCount: expenses.length),
    );
  }
}

// Category icon widget with fallback
class _CategoryIcon extends StatelessWidget {
  final Category? category;

  const _CategoryIcon({this.category});

  @override
  Widget build(BuildContext context) {
    // Use category color if available, fallback to primary
    final color = category?.color ?? AppColors.primary;

    // Use category icon if available, fallback to receipt icon
    final iconData = category?.icon ?? Icons.receipt_long;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(iconData, color: color, size: 20),
    );
  }
}
