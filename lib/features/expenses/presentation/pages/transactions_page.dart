import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/expense.dart';
import '../cubit/category_cubit.dart';
import '../cubit/expense_cubit.dart';
import '../cubit/expense_state.dart';

@RoutePage()
class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text('Transactions', style: AppTextStyles.sectionTitle),
        actions: [
          // Filter button — will wire up in future session
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      // FAB to add new transaction from this screen too
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.router.push(AddExpenseRoute()),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.iconOnColor),
      ),
      body: BlocBuilder<ExpenseCubit, ExpenseState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox(),
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            loaded: (expenses, totalExpenses, totalIncome) {
              if (expenses.isEmpty) {
                return _EmptyState(
                  onAddTap: () => context.router.push(AddExpenseRoute()),
                );
              }
              return _TransactionsList(expenses: expenses);
            },
            error: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.expense,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(message, style: AppTextStyles.bodySecondary),
                  const SizedBox(height: 16),
                  // Retry button on error
                  ElevatedButton(
                    onPressed: () =>
                        context.read<ExpenseCubit>().loadExpenses(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Full transactions list with swipe to delete and pull to refresh
class _TransactionsList extends StatelessWidget {
  final List<Expense> expenses;

  const _TransactionsList({required this.expenses});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      // Pull down to reload from Firebase
      color: AppColors.primary,
      backgroundColor: Theme.of(context).cardColor,
      onRefresh: () => context.read<ExpenseCubit>().loadExpenses(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          final expense = expenses[index];
          return _SwipeToDeleteItem(
            expense: expense,
            onDelete: () => _confirmDelete(context, expense),
          );
        },
      ),
    );
  }

  // Show confirmation dialog before deleting
  // Prevents accidental deletions
  void _confirmDelete(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text(
          'Delete Transaction',
          style: AppTextStyles.sectionTitle,
        ),
        content: Text(
          'Are you sure you want to delete "${expense.title}"?',
          style: AppTextStyles.bodySecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => context.maybePop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              context.maybePop(dialogContext);
              // Use the outer context to access cubit
              // dialogContext does not have access to cubit
              context.read<ExpenseCubit>().deleteExpense(expense.id);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.expense),
            ),
          ),
        ],
      ),
    );
  }
}

// Individual transaction item with swipe to delete gesture
class _SwipeToDeleteItem extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;

  const _SwipeToDeleteItem({required this.expense, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isExpense = expense.type == TransactionType.expense;

    // Look up real category
    final category = context.read<CategoryCubit>().getCategoryById(
      expense.categoryId,
    );

    final color = category?.color ?? AppColors.primary;
    final iconData = category?.icon ?? Icons.receipt_long;

    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.expense,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) async {
        _confirmDelete(context, expense);
        return false;
      },
      child: GestureDetector(
        onTap: () => context.router.push(AddExpenseRoute(expense: expense)),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Real category icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(iconData, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(expense.title, style: AppTextStyles.cardTitle),
                    const SizedBox(height: 4),
                    // Category name under title
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
                    '${isExpense ? '-' : '+'}NPR ${expense.amount.toStringAsFixed(0)}',
                    style: isExpense
                        ? AppTextStyles.expenseAmount
                        : AppTextStyles.incomeAmount,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${expense.date.day}/${expense.date.month}/${expense.date.year}',
                    style: AppTextStyles.bodySecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text(
          'Delete Transaction',
          style: AppTextStyles.sectionTitle,
        ),
        content: Text(
          'Are you sure you want to delete "${expense.title}"?',
          style: AppTextStyles.bodySecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => context.maybePop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              context.maybePop(dialogContext);
              context.read<ExpenseCubit>().deleteExpense(expense.id);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.expense),
            ),
          ),
        ],
      ),
    );
  }
}

// Friendly empty state when no transactions exist
class _EmptyState extends StatelessWidget {
  final VoidCallback onAddTap;

  const _EmptyState({required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          const Text('No transactions yet', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 8),
          const Text(
            'Add your first transaction\nto get started',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: onAddTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Add Transaction',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
