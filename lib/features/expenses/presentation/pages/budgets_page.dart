import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/budget.dart';
import '../cubit/budget_cubit.dart';
import '../cubit/category_cubit.dart';

@RoutePage()
class BudgetsPage extends StatelessWidget {
  const BudgetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      // Budget already loaded at app level — just use existing instance
      value: context.read<BudgetCubit>(),
      child: const _BudgetsView(),
    );
  }
}

class _BudgetsView extends StatelessWidget {
  const _BudgetsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Budgets', style: AppTextStyles.sectionTitle),
        actions: [
          // Add button in app bar — cleaner than FAB for this screen
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () => _showAddBudgetSheet(context),
              icon: const Icon(
                Icons.add_circle_outline,
                color: AppColors.primary,
                size: 18,
              ),
              label: const Text(
                'Add',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<BudgetCubit, BudgetState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox(),
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            loaded: (budgets) {
              if (budgets.isEmpty) {
                return _EmptyState(
                  onAddTap: () => _showAddBudgetSheet(context),
                );
              }
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async =>
                    context.read<BudgetCubit>().loadBudgets(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  itemCount: budgets.length,
                  itemBuilder: (context, index) {
                    return _BudgetCard(item: budgets[index]);
                  },
                ),
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
                    onPressed: () => context.read<BudgetCubit>().loadBudgets(),
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

  void _showAddBudgetSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<BudgetCubit>(),
        child: BlocProvider.value(
          value: context.read<CategoryCubit>(),
          child: const _AddBudgetSheet(),
        ),
      ),
    );
  }
}

// Individual budget card with progress and status message
class _BudgetCard extends StatelessWidget {
  final BudgetWithProgress item;

  const _BudgetCard({required this.item});

  // Returns a contextual message based on spending percentage
  String get _statusMessage {
    if (item.isOverBudget) {
      final excess = item.spent - item.budget.amount;
      return "You've exceeded this budget by ${CurrencyFormatter.format(excess)}";
    }
    if (item.percentage >= 90) {
      return "Almost at your limit! Only ${CurrencyFormatter.format(item.budget.amount - item.spent)} left.";
    }
    if (item.percentage >= 70) {
      return "You're close to your limit. Slow down a little.";
    }
    if (item.percentage >= 50) {
      return "Halfway through your budget. Stay on track!";
    }
    return "You're doing great. Keep it up!";
  }

  // Returns color based on spending percentage
  Color get _statusColor {
    if (item.isOverBudget) return AppColors.expense;
    if (item.percentage >= 70) return AppColors.warning;
    return AppColors.income;
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(item.categoryColorValue);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        // Subtle shadow for depth
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card Header ──────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
            child: Row(
              children: [
                // Category icon with colored background
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.categoryIcon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.categoryName, style: AppTextStyles.cardTitle),
                      const SizedBox(height: 2),
                      Text('Monthly Budget', style: AppTextStyles.label),
                    ],
                  ),
                ),
                // Action buttons — edit and delete
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ActionButton(
                      icon: Icons.edit_outlined,
                      color: AppColors.primary,
                      onTap: () => _showEditSheet(context),
                    ),
                    const SizedBox(width: 4),
                    _ActionButton(
                      icon: Icons.delete_outline_rounded,
                      color: AppColors.expense,
                      onTap: () => _confirmDelete(context),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Amount Info ──────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Spent amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Spent', style: AppTextStyles.label),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(item.spent),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: item.isOverBudget
                            ? AppColors.expense
                            : Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                  ],
                ),
                // Percentage badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.isOverBudget)
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.warning_amber_rounded,
                            color: AppColors.expense,
                            size: 14,
                          ),
                        ),
                      Text(
                        item.isOverBudget
                            ? 'Over budget!'
                            : '${item.percentage.toStringAsFixed(0)}% used',
                        style: TextStyle(
                          color: _statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Budget limit
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Limit', style: AppTextStyles.label),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(item.budget.amount),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Progress Bar ─────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: item.percentage / 100,
                backgroundColor: Theme.of(context).dividerColor,
                valueColor: AlwaysStoppedAnimation<Color>(
                  item.isOverBudget ? AppColors.expense : _statusColor,
                ),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Status Message ───────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _statusColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  item.isOverBudget
                      ? Icons.sentiment_very_dissatisfied_rounded
                      : item.percentage >= 70
                      ? Icons.sentiment_dissatisfied_rounded
                      : Icons.sentiment_satisfied_rounded,
                  color: _statusColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _statusMessage,
                    style: AppTextStyles.bodySecondary.copyWith(
                      color: _statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Budget', style: AppTextStyles.sectionTitle),
        content: Text(
          'Delete the monthly budget for "${item.categoryName}"?',
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
              context.read<BudgetCubit>().deleteBudget(item.budget.id);
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

  void _showEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<BudgetCubit>(),
        child: _EditBudgetSheet(item: item),
      ),
    );
  }
}

// Small circular action button
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

// Bottom sheet form to add a new budget
class _AddBudgetSheet extends StatefulWidget {
  const _AddBudgetSheet();

  @override
  State<_AddBudgetSheet> createState() => _AddBudgetSheetState();
}

class _AddBudgetSheetState extends State<_AddBudgetSheet> {
  final _amountController = TextEditingController();
  String? _selectedCategoryId;
  // ignore: unused_field
  BudgetPeriod _selectedPeriod = BudgetPeriod.monthly;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a budget amount')),
      );
      return;
    }

    // No period parameter — always monthly
    context.read<BudgetCubit>().addBudget(
      categoryId: _selectedCategoryId!,
      amount: double.parse(_amountController.text),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Adjust for keyboard height
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sheet handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Set Monthly Budget', style: AppTextStyles.sectionTitle),
                  Text(
                    'Track your spending by category',
                    style: AppTextStyles.bodySecondary,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Category selector
          const Text('Category', style: AppTextStyles.label),
          const SizedBox(height: 8),
          BlocBuilder<CategoryCubit, CategoryState>(
            builder: (context, state) {
              final categories = state.maybeWhen(
                loaded: (cats) =>
                    cats.where((c) => c.type == 'expense').toList(),
                orElse: () => [],
              );

              return DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                hint: const Text('Select a category'),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                items: categories.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat.id,
                    child: Row(
                      children: [
                        Icon(cat.icon, color: cat.color, size: 18),
                        const SizedBox(width: 10),
                        Text(cat.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedCategoryId = value),
              );
            },
          ),
          const SizedBox(height: 16),

          // Amount field
          const Text('Budget Amount', style: AppTextStyles.label),
          const SizedBox(height: 8),
          TextFormField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              prefixText: 'NPR  ',
              hintText: '0.00',
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Save Budget',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditBudgetSheet extends StatefulWidget {
  final BudgetWithProgress item;

  const _EditBudgetSheet({required this.item});

  @override
  State<_EditBudgetSheet> createState() => _EditBudgetSheetState();
}

class _EditBudgetSheetState extends State<_EditBudgetSheet> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    // Pre-fill with existing budget amount
    _amountController = TextEditingController(
      text: widget.item.budget.amount.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_amountController.text.isEmpty) return;

    context.read<BudgetCubit>().updateBudget(
      id: widget.item.budget.id,
      amount: double.parse(_amountController.text),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final color = Color(widget.item.categoryColorValue);

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Category info header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.item.categoryIcon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Edit Budget', style: AppTextStyles.sectionTitle),
                  Text(
                    widget.item.categoryName,
                    style: AppTextStyles.bodySecondary,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          const Text('New Monthly Limit', style: AppTextStyles.label),
          const SizedBox(height: 8),
          TextFormField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            autofocus: true,
            decoration: InputDecoration(
              prefixText: 'NPR  ',
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Update Budget',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Empty state when no budgets exist
class _EmptyState extends StatelessWidget {
  final VoidCallback onAddTap;

  const _EmptyState({required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                size: 52,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text('No budgets yet', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 8),
            const Text(
              'Set monthly spending limits\nfor your categories',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onAddTap,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Set First Budget',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
