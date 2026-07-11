import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/expense.dart';

// Displays a scrollable list of recent transactions
// Receives pre-filtered list from HomePage (last 5 only)
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

        // Determine if this is an expense or income
        // to show correct color and sign
        final isExpense = expense.type == TransactionType.expense;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Category icon — will be replaced with real
                // category icons when we build the categories feature
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Transaction title and date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(expense.title, style: AppTextStyles.cardTitle),
                      const SizedBox(height: 4),
                      Text(
                        '${expense.date.day}/${expense.date.month}/${expense.date.year}',
                        style: AppTextStyles.bodySecondary,
                      ),
                    ],
                  ),
                ),
                // Amount — negative for expense, positive for income
                Text(
                  '${isExpense ? '-' : '+'}NPR ${expense.amount.toStringAsFixed(0)}',
                  style: isExpense
                      ? AppTextStyles.expenseAmount
                      : AppTextStyles.incomeAmount,
                ),
              ],
            ),
          ),
        );
      }, childCount: expenses.length),
    );
  }
}
