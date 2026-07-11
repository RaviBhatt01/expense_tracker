import 'package:flutter/material.dart';
import '../../domain/entities/expense.dart';

// Displays a scrollable list of recent transactions
// Receives pre-filtered list from HomePage (last 5)
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
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final expense = expenses[index];
        final isExpense = expense.type == TransactionType.expense;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A3E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Category icon placeholder — will use real icons later
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: Color(0xFF6C63FF),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Title and date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${expense.date.day}/${expense.date.month}/${expense.date.year}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Amount — red for expense, green for income
                Text(
                  '${isExpense ? '-' : '+'}NPR ${expense.amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: isExpense
                        ? const Color(0xFFE53935)
                        : const Color(0xFF4CAF50),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }, childCount: expenses.length),
    );
  }
}
