import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/expense.dart';
import '../cubit/category_cubit.dart';
import '../cubit/expense_cubit.dart';
import '../cubit/expense_state.dart';

@RoutePage()
class TransactionDetailPage extends StatefulWidget {
  // Expense passed directly — no need to fetch from Firebase again
  final Expense expense;

  const TransactionDetailPage({super.key, required this.expense});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  late Expense _expense;

  @override
  void initState() {
    super.initState();
    _expense = widget.expense;
  }

  @override
  Widget build(BuildContext context) {
    // Listen to ExpenseCubit — update local expense when list changes
    // This ensures detail page shows updated data after edit
    return BlocListener<ExpenseCubit, ExpenseState>(
      listener: (context, state) {
        state.whenOrNull(
          loaded: (expenses, _, __) {
            // Find updated version of this expense in the new list
            final updated = expenses.firstWhereOrNull(
              (e) => e.id == _expense.id,
            );
            if (updated != null && updated != _expense) {
              setState(() => _expense = updated);
            }
          },
        );
      },
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    // Look up category from already-loaded CategoryCubit
    final category = context.read<CategoryCubit>().getCategoryById(
      _expense.categoryId,
    );

    final color = category?.color ?? AppColors.primary;
    final iconData = category?.icon ?? Icons.category;
    final isExpense = _expense.type == TransactionType.expense;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Back button — pops back to transactions list
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          onPressed: () => context.maybePop(),
        ),
        actions: [
          // Edit button
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: Colors.white,
                size: 16,
              ),
            ),
            onPressed: () =>
                context.router.push(AddExpenseRoute(expense: _expense)),
          ),
          // Delete button
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.expense.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              onPressed: () => _showDeleteDialog(context),
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Hero Section ─────────────────────────────
            _HeroSection(
              color: color,
              iconData: iconData,
              amount: _expense.amount,
              isExpense: isExpense,
              title: _expense.title,
              categoryName: category?.name ?? 'General',
            ),

            // ── Details Section ───────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                children: [
                  // Main info card
                  _DetailCard(
                    children: [
                      _DetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Date',
                        value: DateFormatter.full(_expense.date),
                      ),
                      _DetailDivider(),
                      _DetailRow(
                        icon: Icons.category_outlined,
                        label: 'Category',
                        value: category?.name ?? 'General',
                        valueColor: color,
                      ),
                      _DetailDivider(),
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
                      _DetailDivider(),
                      _DetailRow(
                        icon: Icons.access_time_outlined,
                        label: 'Added on',
                        value: DateFormatter.full(_expense.createdAt),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Note section — only shown if note exists
                  if (_expense.note != null && _expense.note!.isNotEmpty)
                    Column(
                      children: [
                        _DetailCard(
                          children: [
                            _DetailRow(
                              icon: Icons.notes_outlined,
                              label: 'Note',
                              value: _expense.note!,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),

                  // Receipt section — only shown if receipt exists
                  if (_expense.receiptUrl != null &&
                      _expense.receiptUrl!.isNotEmpty)
                    Column(
                      children: [
                        _DetailCard(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.receipt_outlined,
                                          size: 18,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Receipt',
                                        style: AppTextStyles.bodySecondary,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Receipt image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      _expense.receiptUrl!,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, progress) {
                                            if (progress == null) return child;
                                            return Container(
                                              height: 150,
                                              decoration: BoxDecoration(
                                                color: Theme.of(
                                                  context,
                                                ).scaffoldBackgroundColor,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      color: AppColors.primary,
                                                      strokeWidth: 2,
                                                    ),
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showDeleteDialog(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.expense,
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.expense,
                            size: 18,
                          ),
                          label: const Text(
                            'Delete',
                            style: TextStyle(
                              color: AppColors.expense,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.router.push(
                            AddExpenseRoute(expense: _expense),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: const Text(
                            'Edit',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Transaction',
          style: AppTextStyles.sectionTitle,
        ),
        content: Text(
          'Delete "${_expense.title}"? This action cannot be undone.',
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
              context.read<ExpenseCubit>().deleteExpense(_expense.id);
              // Pop back to transactions list after delete
              context.maybePop();
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: AppColors.expense,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Hero section with gradient background using category color
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
      padding: const EdgeInsets.fromLTRB(20, 100, 20, 36),
      decoration: BoxDecoration(
        // Rich gradient using category color
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withOpacity(0.9),
            color.withOpacity(0.3),
            Theme.of(context).scaffoldBackgroundColor,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: Column(
        children: [
          // Large category icon with glow
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Icon(iconData, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 20),

          // Amount — large and prominent
          Text(
            '${isExpense ? '-' : '+'}${CurrencyFormatter.format(amount, showDecimals: true)}',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),

          // Transaction title
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Category chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(iconData, color: Colors.white, size: 14),
                const SizedBox(width: 6),
                Text(
                  categoryName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final List<Widget> children;

  const _DetailCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon with subtle background
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Text(label, style: AppTextStyles.bodySecondary),
            ],
          ),

          Text(
            value,
            style: AppTextStyles.cardTitle.copyWith(color: valueColor),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

class _DetailDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 52,
      endIndent: 16,
      color: Theme.of(context).dividerColor,
    );
  }
}
