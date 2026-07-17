import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';

// Shows income and expense totals side by side
class ExpenseSummaryCard extends StatelessWidget {
  final double totalIncome;
  final double totalExpenses;

  const ExpenseSummaryCard({
    super.key,
    required this.totalIncome,
    required this.totalExpenses,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Income summary
          Expanded(
            child: _SummaryItem(
              label: 'Income',
              amount: totalIncome,
              icon: Icons.arrow_downward,
              color: AppColors.income,
            ),
          ),
          const SizedBox(width: 16),
          // Expense summary
          Expanded(
            child: _SummaryItem(
              label: 'Expenses',
              amount: totalExpenses,
              icon: Icons.arrow_upward,
              color: AppColors.expense,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Colored icon with transparent background
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.label),
              const SizedBox(height: 4),
              Text(
                CurrencyFormatter.format(amount),
                style: AppTextStyles.summaryAmount,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
