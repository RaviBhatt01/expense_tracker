import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/expense.dart';
import '../cubit/category_cubit.dart';
import '../cubit/expense_cubit.dart';

@RoutePage()
class TransactionDetailPage extends StatelessWidget {
  // Expense passed directly — no need to fetch from Firebase again
  final Expense expense;

  const TransactionDetailPage({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    // Look up category from already-loaded CategoryCubit
    final category = context.read<CategoryCubit>().getCategoryById(
      expense.categoryId,
    );

    final color = category?.color ?? AppColors.primary;
    final iconData = category?.icon ?? Icons.category;
    final isExpense = expense.type == TransactionType.expense;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        // Back button — pops back to transactions list
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.maybePop(),
        ),
        title: const Text('Transaction', style: AppTextStyles.sectionTitle),
        actions: [
          // Edit button — opens add/edit form
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () =>
                context.router.push(AddExpenseRoute(expense: expense)),
          ),
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.expense),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Hero Section ─────────────────────────────
            _HeroSection(
              color: color,
              iconData: iconData,
              amount: expense.amount,
              isExpense: isExpense,
              title: expense.title,
              categoryName: category?.name ?? 'General',
            ),
            const SizedBox(height: 24),

            // ── Details Section ───────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _DetailCard(
                    children: [
                      _DetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Date',
                        value: DateFormatter.full(expense.date),
                      ),
                      _Divider(),
                      _DetailRow(
                        icon: Icons.category_outlined,
                        label: 'Category',
                        value: category?.name ?? 'General',
                        valueColor: color,
                      ),
                      _Divider(),
                      _DetailRow(
                        icon: isExpense
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        label: 'Type',
                        value: isExpense ? 'Expense' : 'Income',
                        valueColor: isExpense
                            ? AppColors.expense
                            : AppColors.income,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Note section — only shown if note exists
                  if (expense.note != null && expense.note!.isNotEmpty)
                    _DetailCard(
                      children: [
                        _DetailRow(
                          icon: Icons.notes_outlined,
                          label: 'Note',
                          value: expense.note!,
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // Created at info
                  _DetailCard(
                    children: [
                      _DetailRow(
                        icon: Icons.access_time_outlined,
                        label: 'Created',
                        value: DateFormatter.full(expense.createdAt),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
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
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ExpenseCubit>().deleteExpense(expense.id);
              // Pop back to transactions list after delete
              context.maybePop();
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

// Large hero section at the top showing amount and category
class _HeroSection extends StatelessWidget {
  final Color color;
  final IconData iconData;
  final double amount;
  final bool isExpense;
  final String title;
  final String categoryName;

  const _HeroSection({
    required this.color,
    required this.iconData,
    required this.amount,
    required this.isExpense,
    required this.title,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        // Subtle gradient using category color
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withOpacity(0.15),
            Theme.of(context).scaffoldBackgroundColor,
          ],
        ),
      ),
      child: Column(
        children: [
          // Large category icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: color, size: 36),
          ),
          const SizedBox(height: 20),

          // Amount — large and prominent
          Text(
            '${isExpense ? '-' : '+'}${CurrencyFormatter.format(amount, showDecimals: true)}',
            style: AppTextStyles.balanceAmount.copyWith(
              color: isExpense ? AppColors.expense : AppColors.income,
              fontSize: 40,
            ),
          ),
          const SizedBox(height: 8),

          // Transaction title
          Text(
            title,
            style: AppTextStyles.sectionTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // Category chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              categoryName,
              style: AppTextStyles.bodySecondary.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Rounded card container for detail rows
class _DetailCard extends StatelessWidget {
  final List<Widget> children;

  const _DetailCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

// Single detail row with icon, label, and value
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Icon with subtle background
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),

          // Label
          Text(label, style: AppTextStyles.bodySecondary),
          const Spacer(),

          // Value — right aligned
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.cardTitle.copyWith(color: valueColor),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// Thin divider between rows
class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: Theme.of(context).dividerColor,
    );
  }
}
