import 'package:flutter/material.dart';

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
          // Income card
          Expanded(
            child: _SummaryItem(
              label: 'Income',
              amount: totalIncome,
              icon: Icons.arrow_downward,
              // Green for income
              color: const Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(width: 16),
          // Expense card
          Expanded(
            child: _SummaryItem(
              label: 'Expenses',
              amount: totalExpenses,
              icon: Icons.arrow_upward,
              // Red for expenses
              color: const Color(0xFFE53935),
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
        // Slightly lighter than background for card effect
        color: const Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
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
              Text(
                label,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                'NPR ${amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
