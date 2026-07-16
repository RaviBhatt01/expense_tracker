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
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
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
              // Pass context down so list items can access
              // ScaffoldMessenger and ExpenseCubit correctly
              return _TransactionsList(
                expenses: expenses,
                pageContext: context, // ← outer scaffold context
              );
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
                  ElevatedButton(
                    onPressed: () =>
                        context.read<ExpenseCubit>().loadExpenses(),
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

class _TransactionsList extends StatelessWidget {
  final List<Expense> expenses;
  // pageContext = context from TransactionsPage scaffold
  // needed for ScaffoldMessenger and router access
  final BuildContext pageContext;

  const _TransactionsList({required this.expenses, required this.pageContext});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
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
            // Pass pageContext so delete dialog uses correct context
            onDelete: () => _showDeleteDialog(pageContext, expense),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text(
          'Delete Transaction',
          style: AppTextStyles.sectionTitle,
        ),
        content: Text(
          'Delete "${expense.title}"?',
          style: AppTextStyles.bodySecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => context.router.maybePop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              context.router.maybePop(dialogContext);
              _deleteWithUndo(context, expense);
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

  void _deleteWithUndo(BuildContext context, Expense expense) {
    context.read<ExpenseCubit>().deleteExpense(expense.id);

    // Get the root scaffold messenger — above all nested scaffolds
    final messenger = ScaffoldMessenger.of(
      context.router.navigatorKey.currentContext!,
    );

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('"${expense.title}" deleted'),
          duration: const Duration(seconds: 6),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          backgroundColor: const Color(0xFF323232),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: AppColors.primary,
            onPressed: () {
              context.read<ExpenseCubit>().undoDelete();
              messenger.hideCurrentSnackBar();
            },
          ),
        ),
      );
  }
}

// Individual swipe to delete item
// onDelete callback receives correct context from parent
class _SwipeToDeleteItem extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;

  const _SwipeToDeleteItem({required this.expense, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isExpense = expense.type == TransactionType.expense;

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
      // Return false — we handle removal through cubit
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: GestureDetector(
        // Use auto_route for navigation
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
}

// Empty state widget
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
