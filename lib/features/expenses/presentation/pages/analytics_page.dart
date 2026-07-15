import 'package:auto_route/auto_route.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/analytics_cubit.dart';
import '../cubit/analytics_state.dart';

@RoutePage()
class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      // Use existing AnalyticsCubit from app level
      // BlocProvider.value → use existing instance, don't create new
      value: context.read<AnalyticsCubit>()..loadAnalytics(),
      child: const _AnalyticsView(),
    );
  }
}

class _AnalyticsView extends StatelessWidget {
  const _AnalyticsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text('Analytics', style: AppTextStyles.sectionTitle),
      ),
      body: BlocBuilder<AnalyticsCubit, AnalyticsState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox(),
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            loaded: (expenses, totalExpenses, totalIncome, breakdown, period) {
              return CustomScrollView(
                slivers: [
                  // Period filter chips
                  SliverToBoxAdapter(
                    child: _PeriodFilter(selectedPeriod: period),
                  ),
                  // Summary cards
                  SliverToBoxAdapter(
                    child: _SummarySection(
                      totalExpenses: totalExpenses,
                      totalIncome: totalIncome,
                    ),
                  ),
                  // Donut chart
                  SliverToBoxAdapter(child: _DonutChart(breakdown: breakdown)),
                  // Category breakdown list
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: const Text(
                        'Spending by Category',
                        style: AppTextStyles.sectionTitle,
                      ),
                    ),
                  ),
                  if (breakdown.isEmpty)
                    const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Text(
                            'No expense data for this period',
                            style: AppTextStyles.bodySecondary,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _CategoryRow(
                          item: breakdown[index],
                          totalExpenses: totalExpenses,
                        ),
                        childCount: breakdown.length,
                      ),
                    ),
                ],
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
                        context.read<AnalyticsCubit>().loadAnalytics(),
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

// Period filter — week, month, year chips
class _PeriodFilter extends StatelessWidget {
  final AnalyticsPeriod selectedPeriod;

  const _PeriodFilter({required this.selectedPeriod});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: AnalyticsPeriod.values.map((period) {
          final isSelected = period == selectedPeriod;
          final label = switch (period) {
            AnalyticsPeriod.week => 'This Week',
            AnalyticsPeriod.month => 'This Month',
            AnalyticsPeriod.year => 'This Year',
          };

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () =>
                  context.read<AnalyticsCubit>().loadAnalytics(period: period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  // Selected → primary color, not selected → surface
                  color: isSelected
                      ? AppColors.primary
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: AppTextStyles.cardSubTitle.copyWith(
                    color: isSelected ? Colors.white : Colors.black,
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Income vs expense summary for selected period
class _SummarySection extends StatelessWidget {
  final double totalExpenses;
  final double totalIncome;

  const _SummarySection({
    required this.totalExpenses,
    required this.totalIncome,
  });

  @override
  Widget build(BuildContext context) {
    final balance = totalIncome - totalExpenses;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _SummaryItem(
              label: 'Income',
              amount: totalIncome,
              color: AppColors.income,
            ),
            // Divider between items
            Container(height: 40, width: 1, color: AppColors.divider),
            _SummaryItem(
              label: 'Expenses',
              amount: totalExpenses,
              color: AppColors.expense,
            ),
            Container(height: 40, width: 1, color: AppColors.divider),
            _SummaryItem(
              label: 'Balance',
              amount: balance,
              // Green if positive balance, red if negative
              color: balance >= 0 ? AppColors.income : AppColors.expense,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 4),
        Text(
          'NPR ${amount.toStringAsFixed(0)}',
          style: AppTextStyles.cardTitle.copyWith(color: color),
        ),
      ],
    );
  }
}

// Donut chart showing category spending breakdown
class _DonutChart extends StatelessWidget {
  final List<CategoryAnalytics> breakdown;

  const _DonutChart({required this.breakdown});

  @override
  Widget build(BuildContext context) {
    if (breakdown.isEmpty) {
      return const SizedBox(height: 200);
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        height: 220,
        child: PieChart(
          PieChartData(
            // Convert CategoryAnalytics to PieChartSectionData
            sections: breakdown.map((item) {
              return PieChartSectionData(
                value: item.amount,
                color: Color(item.colorValue),
                // Only show percentage on larger sections
                title: item.percentage > 10
                    ? '${item.percentage.toStringAsFixed(0)}%'
                    : '',
                titleStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                radius: 60,
              );
            }).toList(),
            // centerSpaceRadius creates the donut hole
            centerSpaceRadius: 60,
            sectionsSpace: 2, // gap between sections
          ),
        ),
      ),
    );
  }
}

// Single category row in breakdown list
class _CategoryRow extends StatelessWidget {
  final CategoryAnalytics item;
  final double totalExpenses;

  const _CategoryRow({required this.item, required this.totalExpenses});

  @override
  Widget build(BuildContext context) {
    final color = Color(item.colorValue);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Color dot representing category
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.categoryName,
                    style: AppTextStyles.cardTitle,
                  ),
                ),
                Text(
                  'NPR ${item.amount.toStringAsFixed(0)}',
                  style: AppTextStyles.cardTitle,
                ),
                const SizedBox(width: 8),
                Text(
                  '${item.percentage.toStringAsFixed(1)}%',
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Progress bar showing percentage of total
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: item.percentage / 100,
                backgroundColor: AppColors.divider,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
