import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/budget.dart';
import '../cubit/budget_cubit.dart';
import '../cubit/category_cubit.dart';

@RoutePage()
class BudgetsPage extends StatelessWidget {
  const BudgetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      // Use existing BudgetCubit from app level
      value: context.read<BudgetCubit>()..loadBudgets(),
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
      ),
      // FAB to add new budget
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetSheet(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
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
              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: budgets.length,
                itemBuilder: (context, index) {
                  return _BudgetCard(item: budgets[index]);
                },
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

  // Bottom sheet to add a new budget
  void _showAddBudgetSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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

// Individual budget card with progress bar
class _BudgetCard extends StatelessWidget {
  final BudgetWithProgress item;

  const _BudgetCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = Color(item.categoryColorValue);
    final remaining = item.budget.amount - item.spent;

    return Dismissible(
      key: Key(item.budget.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.expense,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) async {
        context.read<BudgetCubit>().deleteBudget(item.budget.id);
        return false;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Category icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(item.categoryIcon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.categoryName, style: AppTextStyles.cardTitle),
                      Text(
                        item.budget.period.name.toUpperCase(),
                        style: AppTextStyles.bodySecondary.copyWith(
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                // Over budget warning icon
                if (item.isOverBudget)
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.warning,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: item.percentage / 100,
                // Red when over budget, category color otherwise
                backgroundColor: Theme.of(context).dividerColor,
                valueColor: AlwaysStoppedAnimation<Color>(
                  item.isOverBudget ? AppColors.expense : color,
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 12),
            // Spent vs budget amounts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'NPR ${item.spent.toStringAsFixed(0)} spent',
                  style: AppTextStyles.bodySecondary,
                ),
                Text(
                  item.isOverBudget
                      ? 'Over by NPR ${(-remaining).toStringAsFixed(0)}'
                      : 'NPR ${remaining.toStringAsFixed(0)} left',
                  style: AppTextStyles.bodySecondary.copyWith(
                    color: item.isOverBudget
                        ? AppColors.expense
                        : AppColors.income,
                  ),
                ),
              ],
            ),
          ],
        ),
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

    context.read<BudgetCubit>().addBudget(
      categoryId: _selectedCategoryId!,
      amount: double.parse(_amountController.text),
      period: _selectedPeriod,
    );

    context.router.maybePop(context);
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
          const Text('Add Budget', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 20),

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
                hint: const Text('Select category'),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: categories.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat.id,
                    child: Row(
                      children: [
                        Icon(cat.icon, color: cat.color, size: 18),
                        const SizedBox(width: 8),
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
              prefixText: 'NPR ',
              hintText: '0.00',
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Period selector
          const Text('Period', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Row(
            children: BudgetPeriod.values.map((period) {
              final isSelected = period == _selectedPeriod;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPeriod = period),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        period.name[0].toUpperCase() + period.name.substring(1),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _submit,
              child: const Text(
                'Save Budget',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          const Text('No budgets yet', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 8),
          const Text(
            'Set spending limits for your\ncategories to track your goals',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: onAddTap,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Add Budget',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
