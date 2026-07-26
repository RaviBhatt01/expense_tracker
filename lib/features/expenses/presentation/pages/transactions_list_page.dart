import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/expense.dart';
import '../cubit/category_cubit.dart';
import '../cubit/expense_cubit.dart';
import '../cubit/expense_state.dart';

@RoutePage()
class TransactionsListPage extends StatefulWidget {
  const TransactionsListPage({super.key});

  @override
  State<TransactionsListPage> createState() => _TransactionsListPageState();
}

class _TransactionsListPageState extends State<TransactionsListPage> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: BlocBuilder<ExpenseCubit, ExpenseState>(
          builder: (context, state) {
            // Subtitle shows total entries count
            final count = state.maybeWhen(
              loaded: (expenses, _, __) => expenses.length,
              orElse: () => 0,
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Transactions', style: AppTextStyles.sectionTitle),
                if (count > 0)
                  Text(
                    '$count ${count == 1 ? 'entry' : 'entries'}',
                    style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
                  ),
              ],
            );
          },
        ),
        actions: [
          BlocBuilder<ExpenseCubit, ExpenseState>(
            builder: (context, state) {
              // Read hasActiveFilters inside builder so it
              // re-evaluates every time state changes
              final hasFilters = context.read<ExpenseCubit>().hasActiveFilters;
              if (!hasFilters) return const SizedBox();
              return TextButton(
                onPressed: () {
                  _searchController.clear();
                  context.read<ExpenseCubit>().clearFilters();
                },
                child: const Text(
                  'Clear',
                  style: TextStyle(
                    color: AppColors.expense,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'transactions_fab',
        onPressed: () => context.router.push(AddExpenseRoute()),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.iconOnColor),
      ),
      body: GestureDetector(
        // Dismiss keyboard when tapping anywhere outside search
        onTap: () => _searchFocusNode.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: [
            // ── Search Bar ───────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode, // ← attach focus node
                // Prevent auto focus when returning to page
                autofocus: false,
                onChanged: (query) =>
                    context.read<ExpenseCubit>().search(query),
                decoration: InputDecoration(
                  hintText: 'Search transactions...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textSecondary,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            context.read<ExpenseCubit>().search('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                ),
              ),
            ),

            // ── Filter Chips + Filter Icon ────────────────
            _FilterChipsRow(onFilterTap: () => _showFilterSheet(context)),

            // ── Active Filter Summary Card ─────────────────
            // Shows when any filter is active
            BlocBuilder<ExpenseCubit, ExpenseState>(
              builder: (context, state) {
                final cubit = context.read<ExpenseCubit>();
                if (!cubit.hasActiveFilters) return const SizedBox();
                return state.maybeWhen(
                  loaded: (expenses, totalExpenses, totalIncome) =>
                      _FilterSummaryCard(
                        count: expenses.length,
                        totalExpenses: totalExpenses,
                        totalIncome: totalIncome,
                      ),
                  orElse: () => const SizedBox(),
                );
              },
            ),

            // ── Transactions List ─────────────────────────
            Expanded(
              child: BlocBuilder<ExpenseCubit, ExpenseState>(
                builder: (context, state) {
                  return state.when(
                    initial: () => const SizedBox(),
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                    loaded: (expenses, totalExpenses, totalIncome) {
                      if (expenses.isEmpty) {
                        return _EmptyState(
                          onAddTap: () =>
                              context.router.push(AddExpenseRoute()),
                        );
                      }
                      return _TransactionsList(
                        expenses: expenses,
                        pageContext: context,
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
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<ExpenseCubit>()),
          BlocProvider.value(value: context.read<CategoryCubit>()),
        ],
        child: const _FilterSheet(),
      ),
    );
  }
}

// Filter chips row with filter icon on the right
class _FilterChipsRow extends StatelessWidget {
  final VoidCallback onFilterTap;

  const _FilterChipsRow({required this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseCubit, ExpenseState>(
      builder: (context, state) {
        final cubit = context.read<ExpenseCubit>();
        final currentType = cubit.currentFilterType;

        return SizedBox(
          height: 52,
          child: Row(
            children: [
              Expanded(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  children: [
                    // All — selected when no type filter active
                    _FilterChip(
                      label: 'All',
                      isSelected: currentType == null,
                      onTap: () => cubit.filterByType(null),
                    ),
                    const SizedBox(width: 8),
                    // Expense filter
                    _FilterChip(
                      label: 'Expense',
                      icon: Icons.arrow_upward_rounded,
                      color: AppColors.expense,
                      isSelected: currentType == TransactionType.expense,
                      onTap: () => cubit.filterByType(TransactionType.expense),
                    ),
                    const SizedBox(width: 8),
                    // Income filter
                    _FilterChip(
                      label: 'Income',
                      icon: Icons.arrow_downward_rounded,
                      color: AppColors.income,
                      isSelected: currentType == TransactionType.income,
                      onTap: () => cubit.filterByType(TransactionType.income),
                    ),
                  ],
                ),
              ),
              // Filter icon button on far right
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: onFilterTap,
                  child: BlocBuilder<ExpenseCubit, ExpenseState>(
                    builder: (context, state) {
                      // Show active dot when advanced filters are on
                      final hasAdvanced =
                          context.read<ExpenseCubit>().currentDateRange != null;
                      return Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.tune_rounded,
                              color: hasAdvanced
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              size: 20,
                            ),
                          ),
                          if (hasAdvanced)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    this.color,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withOpacity(0.12)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: chipColor),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTextStyles.bodySecondary.copyWith(
                color: isSelected ? chipColor : null,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Filter summary card — shows when filters are active
class _FilterSummaryCard extends StatelessWidget {
  final int count;
  final double totalExpenses;
  final double totalIncome;

  const _FilterSummaryCard({
    required this.count,
    required this.totalExpenses,
    required this.totalIncome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_alt_rounded, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Text(
            '$count results',
            style: AppTextStyles.bodySecondary.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          // Income summary
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.income,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                CurrencyFormatter.compact(totalIncome),
                style: AppTextStyles.bodySecondary.copyWith(
                  color: AppColors.income,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Expense summary
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.expense,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                CurrencyFormatter.compact(totalExpenses),
                style: AppTextStyles.bodySecondary.copyWith(
                  color: AppColors.expense,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Groups transactions by date — each group has a date header + list
class _TransactionsList extends StatelessWidget {
  final List<Expense> expenses;
  final BuildContext pageContext;

  const _TransactionsList({required this.expenses, required this.pageContext});

  @override
  Widget build(BuildContext context) {
    // Group expenses by date (day only, ignoring time)
    final grouped = <String, List<Expense>>{};
    for (final expense in expenses) {
      final dateKey =
          '${expense.date.year}-${expense.date.month}-${expense.date.day}';
      grouped.putIfAbsent(dateKey, () => []).add(expense);
    }

    // Build list of date sections
    final sections = grouped.entries.toList();

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: Theme.of(context).cardColor,
      onRefresh: () => context.read<ExpenseCubit>().loadExpenses(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        itemCount: sections.length,
        itemBuilder: (context, sectionIndex) {
          final section = sections[sectionIndex];
          final sectionExpenses = section.value;
          // Use the first expense's date for the header
          final date = sectionExpenses.first.date;

          // Daily totals for this section
          final dayExpense = sectionExpenses
              .where((e) => e.type == TransactionType.expense)
              .fold(0.0, (sum, e) => sum + e.amount);
          final dayIncome = sectionExpenses
              .where((e) => e.type == TransactionType.income)
              .fold(0.0, (sum, e) => sum + e.amount);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Date Header ──────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Row(
                  children: [
                    Text(
                      DateFormatter.format(date),
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    // Daily summary — income and expense
                    if (dayIncome > 0)
                      Text(
                        '+${CurrencyFormatter.compact(dayIncome)}',
                        style: AppTextStyles.bodySecondary.copyWith(
                          color: AppColors.income,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    if (dayIncome > 0 && dayExpense > 0)
                      const SizedBox(width: 8),
                    if (dayExpense > 0)
                      Text(
                        '-${CurrencyFormatter.compact(dayExpense)}',
                        style: AppTextStyles.bodySecondary.copyWith(
                          color: AppColors.expense,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),

              // ── Transactions Card for this date ───────
              Container(
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
                child: Column(
                  children: sectionExpenses.asMap().entries.map((entry) {
                    final index = entry.key;
                    final expense = entry.value;
                    final isLast = index == sectionExpenses.length - 1;

                    return Column(
                      children: [
                        _SwipeToDeleteItem(
                          expense: expense,
                          onDelete: () =>
                              _showDeleteDialog(pageContext, expense),
                          onTap: () => context.router.push(
                            TransactionDetailRoute(expense: expense),
                          ),
                        ),
                        if (!isLast)
                          Divider(
                            height: 1,
                            indent: 68,
                            endIndent: 16,
                            color: Theme.of(context).dividerColor,
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
              _deleteWithUndo(context, expense);
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

  void _deleteWithUndo(BuildContext context, Expense expense) {
    context.read<ExpenseCubit>().deleteExpense(expense.id);

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
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 80),
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

// Individual swipe to delete item — no card decoration
// Card is handled by the date group container
class _SwipeToDeleteItem extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _SwipeToDeleteItem({
    required this.expense,
    required this.onDelete,
    required this.onTap,
  });

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
        decoration: BoxDecoration(
          color: AppColors.expense,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
      // Return false — we handle removal through cubit
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Category icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(iconData, color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(expense.title, style: AppTextStyles.cardTitle),
                      const SizedBox(height: 2),
                      Text(
                        category?.name ?? 'General',
                        style: AppTextStyles.bodySecondary,
                      ),
                    ],
                  ),
                ),
                // Amount
                Text(
                  '${isExpense ? '-' : '+'}${CurrencyFormatter.format(expense.amount)}',
                  style: isExpense
                      ? AppTextStyles.expenseAmount
                      : AppTextStyles.incomeAmount,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Filter & Sort bottom sheet
class _FilterSheet extends StatefulWidget {
  const _FilterSheet();

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late SortOrder _selectedSort;
  late Set<String> _selectedCategoryIds;
  String? _selectedDatePreset;
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ExpenseCubit>();
    _selectedSort = cubit.currentSortOrder;
    _selectedCategoryIds = cubit.currentFilterCategoryId != null
        ? {cubit.currentFilterCategoryId!}
        : {};
    _selectedDatePreset = null;
  }

  void _applyFilters() {
    final cubit = context.read<ExpenseCubit>();
    cubit.sortBy(_selectedSort);

    // Apply category filter — use first selected if any
    cubit.filterByCategory(
      _selectedCategoryIds.isNotEmpty ? _selectedCategoryIds.first : null,
    );

    // Apply date range
    cubit.filterByDateRange(_customRange);

    Navigator.pop(context);
  }

  void _applyDatePreset(String preset) {
    final now = DateTime.now();
    setState(() {
      _selectedDatePreset = preset;
      switch (preset) {
        case 'last7':
          _customRange = DateTimeRange(
            start: now.subtract(const Duration(days: 7)),
            end: now,
          );
        case 'last30':
          _customRange = DateTimeRange(
            start: now.subtract(const Duration(days: 30)),
            end: now,
          );
        case 'thisMonth':
          _customRange = DateTimeRange(
            start: DateTime(now.year, now.month, 1),
            end: now,
          );
        default:
          _customRange = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: SingleChildScrollView(
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

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Filter & Sort', style: AppTextStyles.sectionTitle),
              ],
            ),
            const SizedBox(height: 24),

            // ── Sort Card ──────────────────────────────
            const Text('SORT BY', style: AppTextStyles.label),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _SortOption(
                    label: 'Newest First',
                    icon: Icons.arrow_downward_rounded,
                    isSelected: _selectedSort == SortOrder.newestFirst,
                    onTap: () =>
                        setState(() => _selectedSort = SortOrder.newestFirst),
                  ),
                  _SheetDivider(),
                  _SortOption(
                    label: 'Oldest First',
                    icon: Icons.arrow_upward_rounded,
                    isSelected: _selectedSort == SortOrder.oldestFirst,
                    onTap: () =>
                        setState(() => _selectedSort = SortOrder.oldestFirst),
                  ),
                  _SheetDivider(),
                  _SortOption(
                    label: 'Highest Amount',
                    icon: Icons.trending_up_rounded,
                    isSelected: _selectedSort == SortOrder.highestAmount,
                    onTap: () =>
                        setState(() => _selectedSort = SortOrder.highestAmount),
                  ),
                  _SheetDivider(),
                  _SortOption(
                    label: 'Lowest Amount',
                    icon: Icons.trending_down_rounded,
                    isSelected: _selectedSort == SortOrder.lowestAmount,
                    onTap: () =>
                        setState(() => _selectedSort = SortOrder.lowestAmount),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Date Range Card ────────────────────────
            const Text('DATE RANGE', style: AppTextStyles.label),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _DatePresetChip(
                  label: 'Last 7 days',
                  isSelected: _selectedDatePreset == 'last7',
                  onTap: () => _applyDatePreset('last7'),
                ),
                _DatePresetChip(
                  label: 'Last 30 days',
                  isSelected: _selectedDatePreset == 'last30',
                  onTap: () => _applyDatePreset('last30'),
                ),
                _DatePresetChip(
                  label: 'This month',
                  isSelected: _selectedDatePreset == 'thisMonth',
                  onTap: () => _applyDatePreset('thisMonth'),
                ),
                _DatePresetChip(
                  label: 'Custom range',
                  isSelected: _selectedDatePreset == 'custom',
                  onTap: () async {
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      builder: (context, child) => Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: AppColors.primary,
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (range != null) {
                      setState(() {
                        _selectedDatePreset = 'custom';
                        _customRange = range;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Categories ─────────────────────────────
            const Text('CATEGORIES', style: AppTextStyles.label),
            const SizedBox(height: 10),
            BlocBuilder<CategoryCubit, CategoryState>(
              builder: (context, state) {
                final categories = state.maybeWhen(
                  loaded: (cats) => cats,
                  orElse: () => <Category>[],
                );

                return SizedBox(
                  height: 64,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected = _selectedCategoryIds.contains(cat.id);
                      final color = cat.color;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedCategoryIds.remove(cat.id);
                            } else {
                              _selectedCategoryIds.add(cat.id);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withOpacity(0.15)
                                : Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? color : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(cat.icon, color: color, size: 18),
                              const SizedBox(height: 4),
                              Text(
                                cat.name.split(' ').first,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected
                                      ? color
                                      : AppColors.textSecondary,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 28),

            // Apply button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
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
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: isSelected ? AppColors.primary : null,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DatePresetChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DatePresetChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.12)
              : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySecondary.copyWith(
            color: isSelected ? AppColors.primary : null,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _SheetDivider extends StatelessWidget {
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
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No transactions yet',
              style: AppTextStyles.sectionTitle,
            ),
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
                'Add Transaction',
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
