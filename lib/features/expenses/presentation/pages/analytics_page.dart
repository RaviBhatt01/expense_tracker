import 'package:auto_route/auto_route.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../cubit/analytics_cubit.dart';
import '../cubit/expense_cubit.dart';

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Analytics', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 4),
            Text(
              'Your money, visualized',
              style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
      body: BlocBuilder<AnalyticsCubit, AnalyticsState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox(),
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            loaded:
                (
                  expenses,
                  totalExpenses,
                  totalIncome,
                  breakdown,
                  period,
                  monthlyComparisons,
                  dailySpending,
                ) {
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async =>
                        context.read<AnalyticsCubit>().loadAnalytics(),
                    child: CustomScrollView(
                      slivers: [
                        // ── Period Filter ──────────────────────
                        SliverToBoxAdapter(
                          child: _PeriodFilter(selectedPeriod: period),
                        ),

                        // ── Summary Card ───────────────────────
                        SliverToBoxAdapter(
                          child: _SummarySection(
                            totalExpenses: totalExpenses,
                            totalIncome: totalIncome,
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 16)),

                        // ── Income vs Expense Bar Chart ────────
                        SliverToBoxAdapter(
                          child: _IncomeVsExpenseCard(
                            comparisons: monthlyComparisons,
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 16)),

                        // ── Weekly Trend Line Chart ────────────
                        SliverToBoxAdapter(
                          child: _WeeklyTrendCard(dailySpending: dailySpending),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 16)),

                        // ── Spending by Category ───────────────
                        SliverToBoxAdapter(
                          child: _SpendingByCategoryCard(
                            breakdown: breakdown,
                            totalExpenses: totalExpenses,
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 32)),
                      ],
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
                    onPressed: () =>
                        context.read<AnalyticsCubit>().loadAnalytics(),
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

// ── Reusable analytics card shell ─────────────────────────────────────────────
class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _AnalyticsCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
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
          // Card header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.sectionTitle),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.bodySecondary),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

// ── Period filter chips ────────────────────────────────────────────────────────
class _PeriodFilter extends StatelessWidget {
  final AnalyticsPeriod selectedPeriod;

  const _PeriodFilter({required this.selectedPeriod});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: AnalyticsPeriod.values.map((period) {
          final isSelected = period == selectedPeriod;
          final label = switch (period) {
            AnalyticsPeriod.week => 'Week',
            AnalyticsPeriod.month => 'Month',
            AnalyticsPeriod.year => 'Year',
          };

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                final allExpenses = context.read<ExpenseCubit>().allExpenses;
                context.read<AnalyticsCubit>().processExpenses(
                  allExpenses: allExpenses,
                  period: period,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  // Selected → primary color, not selected → card color
                  color: isSelected
                      ? AppColors.primary
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
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

// ── Summary section ────────────────────────────────────────────────────────────
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(
            label: 'Income',
            amount: totalIncome,
            color: AppColors.income,
            icon: Icons.arrow_downward_rounded,
          ),
          Container(
            height: 40,
            width: 1,
            color: Theme.of(context).dividerColor,
          ),
          _SummaryItem(
            label: 'Expenses',
            amount: totalExpenses,
            color: AppColors.expense,
            icon: Icons.arrow_upward_rounded,
          ),
          Container(
            height: 40,
            width: 1,
            color: Theme.of(context).dividerColor,
          ),
          _SummaryItem(
            label: 'Balance',
            amount: balance,
            // Green if positive balance, red if negative
            color: balance >= 0 ? AppColors.income : AppColors.expense,
            icon: balance >= 0
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(height: 6),
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 4),
        Text(
          CurrencyFormatter.compact(amount),
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ── Income vs Expense grouped bar chart ───────────────────────────────────────
class _IncomeVsExpenseCard extends StatefulWidget {
  final List<MonthlyComparison> comparisons;

  const _IncomeVsExpenseCard({required this.comparisons});

  @override
  State<_IncomeVsExpenseCard> createState() => _IncomeVsExpenseCardState();
}

class _IncomeVsExpenseCardState extends State<_IncomeVsExpenseCard> {
  int? _touchedGroupIndex;

  @override
  Widget build(BuildContext context) {
    // Find max value for Y axis scaling
    final maxValue = widget.comparisons.fold<double>(
      0,
      (max, m) => [max, m.income, m.expense].reduce((a, b) => a > b ? a : b),
    );

    // Check if all months have zero data
    final hasData = widget.comparisons.any(
      (c) => c.income > 0 || c.expense > 0,
    );

    return _AnalyticsCard(
      title: 'Income vs Expense',
      subtitle: 'Last 6 months',
      child: hasData
          ? Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: maxValue * 1.2, // 20% headroom above max
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchCallback: (event, response) {
                            setState(() {
                              if (response?.spot != null &&
                                  event is! FlPointerExitEvent) {
                                _touchedGroupIndex =
                                    response!.spot!.touchedBarGroupIndex;
                              } else {
                                _touchedGroupIndex = null;
                              }
                            });
                          },
                          // Custom tooltip showing month, income, expense
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (_) => Theme.of(context).cardColor,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final data = widget.comparisons[groupIndex];
                              return BarTooltipItem(
                                '${data.month}\n',
                                AppTextStyles.cardTitle,
                                children: [
                                  TextSpan(
                                    text:
                                        '▲ ${CurrencyFormatter.compact(data.income)}\n',
                                    style: const TextStyle(
                                      color: AppColors.income,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        '▼ ${CurrencyFormatter.compact(data.expense)}',
                                    style: const TextStyle(
                                      color: AppColors.expense,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          // Y-axis labels on left
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 44,
                              getTitlesWidget: (value, meta) {
                                if (value == 0) return const SizedBox();
                                return Text(
                                  CurrencyFormatter.compact(value),
                                  style: AppTextStyles.bodySecondary.copyWith(
                                    fontSize: 10,
                                  ),
                                );
                              },
                            ),
                          ),
                          // Month labels on bottom
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 ||
                                    index >= widget.comparisons.length) {
                                  return const SizedBox();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    widget.comparisons[index].month,
                                    style: AppTextStyles.bodySecondary.copyWith(
                                      fontSize: 11,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          // Dashed horizontal grid lines
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Theme.of(context).dividerColor,
                            strokeWidth: 1,
                            dashArray: [4, 4],
                          ),
                          drawVerticalLine: false,
                        ),
                        borderData: FlBorderData(show: false),
                        // Build grouped bars for each month
                        barGroups: widget.comparisons.asMap().entries.map((
                          entry,
                        ) {
                          final index = entry.key;
                          final data = entry.value;
                          final isTouched = _touchedGroupIndex == index;

                          return BarChartGroupData(
                            x: index,
                            // Spacing between the two bars in a group
                            groupVertically: false,
                            barRods: [
                              // Income bar — left, green
                              BarChartRodData(
                                toY: data.income,
                                color: isTouched
                                    ? AppColors.income
                                    : AppColors.income.withOpacity(0.85),
                                width: 10,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                              // Expense bar — right, red
                              BarChartRodData(
                                toY: data.expense,
                                color: isTouched
                                    ? AppColors.expense
                                    : AppColors.expense.withOpacity(0.85),
                                width: 10,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                            ],
                            barsSpace: 4, // gap between income and expense bar
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _LegendDot(color: AppColors.income, label: 'Income'),
                      const SizedBox(width: 24),
                      _LegendDot(color: AppColors.expense, label: 'Expense'),
                    ],
                  ),
                ],
              ),
            )
          : _EmptyChartState(
              icon: Icons.bar_chart_outlined,
              message:
                  'No data for the last 6 months.\nAdd transactions to see comparison.',
            ),
    );
  }
}

// Small legend dot with label
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.bodySecondary),
      ],
    );
  }
}

// ── Weekly trend line chart ────────────────────────────────────────────────────
class _WeeklyTrendCard extends StatefulWidget {
  final List<DailySpending> dailySpending;

  const _WeeklyTrendCard({required this.dailySpending});

  @override
  State<_WeeklyTrendCard> createState() => _WeeklyTrendCardState();
}

class _WeeklyTrendCardState extends State<_WeeklyTrendCard> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final maxAmount = widget.dailySpending.fold<double>(
      0,
      (max, d) => d.amount > max ? d.amount : max,
    );

    // Check if all days have zero spending
    final hasData = widget.dailySpending.any((d) => d.amount > 0);

    return _AnalyticsCard(
      title: 'Weekly Trend',
      subtitle: 'Last 7 days of spending',
      child: hasData
          ? Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: maxAmount * 1.3,
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchCallback: (event, response) {
                        setState(() {
                          if (response?.lineBarSpots != null &&
                              event is! FlPointerExitEvent) {
                            _touchedIndex =
                                response!.lineBarSpots!.first.spotIndex;
                          } else {
                            _touchedIndex = null;
                          }
                        });
                      },
                      // Tooltip on touch showing day and amount
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) => Theme.of(context).cardColor,
                        getTooltipItems: (spots) {
                          return spots.map((spot) {
                            final day = widget.dailySpending[spot.spotIndex];
                            return LineTooltipItem(
                              '${day.day}\n${CurrencyFormatter.format(day.amount)}',
                              AppTextStyles.cardTitle.copyWith(
                                color: AppColors.primary,
                                fontSize: 12,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      // Dashed horizontal grid lines
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Theme.of(context).dividerColor,
                        strokeWidth: 1,
                        dashArray: [4, 4],
                      ),
                    ),
                    titlesData: FlTitlesData(
                      // Day labels on X axis
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 ||
                                index >= widget.dailySpending.length) {
                              return const SizedBox();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                widget.dailySpending[index].day,
                                style: AppTextStyles.bodySecondary.copyWith(
                                  fontSize: 10,
                                  color: _touchedIndex == index
                                      ? AppColors.primary
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Amount labels on Y axis
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 44,
                          getTitlesWidget: (value, meta) {
                            if (value == 0) return const SizedBox();
                            return Text(
                              CurrencyFormatter.compact(value),
                              style: AppTextStyles.bodySecondary.copyWith(
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: widget.dailySpending
                            .asMap()
                            .entries
                            .map(
                              (e) => FlSpot(e.key.toDouble(), e.value.amount),
                            )
                            .toList(),
                        // Smooth curved line
                        isCurved: true,
                        curveSmoothness: 0.35,
                        color: AppColors.primary,
                        barWidth: 3,
                        // Gradient fill under the line
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.primary.withOpacity(0.3),
                              AppColors.primary.withOpacity(0.0),
                            ],
                          ),
                        ),
                        // Circular markers on each data point
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, bar, index) {
                            final isTouched = _touchedIndex == index;
                            return FlDotCirclePainter(
                              radius: isTouched ? 6 : 4,
                              color: isTouched
                                  ? AppColors.primary
                                  : Theme.of(context).cardColor,
                              strokeWidth: 2.5,
                              strokeColor: AppColors.primary,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  // Smooth animation when chart loads
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                ),
              ),
            )
          : _EmptyChartState(
              icon: Icons.show_chart_outlined,
              message:
                  'No spending in the last 7 days.\nAdd expenses to see your trend.',
            ),
    );
  }
}

// ── Spending by Category card ──────────────────────────────────────────────────
class _SpendingByCategoryCard extends StatefulWidget {
  final List<CategoryAnalytics> breakdown;
  final double totalExpenses;

  const _SpendingByCategoryCard({
    required this.breakdown,
    required this.totalExpenses,
  });

  @override
  State<_SpendingByCategoryCard> createState() =>
      _SpendingByCategoryCardState();
}

class _SpendingByCategoryCardState extends State<_SpendingByCategoryCard> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.breakdown.isEmpty) {
      return _AnalyticsCard(
        title: 'Spending by Category',
        subtitle: 'No expense data for this period',
        child: const Padding(
          padding: EdgeInsets.all(40),
          child: Center(
            child: Text(
              'Add some expenses to see breakdown',
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return _AnalyticsCard(
      title: 'Spending by Category',
      subtitle:
          'This period  •  ${widget.breakdown.length} categories  •  ${CurrencyFormatter.format(widget.totalExpenses)}',
      child: Column(
        children: [
          // ── Donut chart + legend side by side ──────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Donut chart with center text
                SizedBox(
                  width: 160,
                  height: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (event, response) {
                              setState(() {
                                if (response?.touchedSection != null &&
                                    event is! FlPointerExitEvent) {
                                  _touchedIndex = response!
                                      .touchedSection!
                                      .touchedSectionIndex;
                                } else {
                                  _touchedIndex = null;
                                }
                              });
                            },
                          ),
                          sections: widget.breakdown.asMap().entries.map((
                            entry,
                          ) {
                            final index = entry.key;
                            final item = entry.value;
                            final isTouched = _touchedIndex == index;

                            return PieChartSectionData(
                              value: item.amount,
                              color: Color(item.colorValue),
                              // No title text on sections — legend handles it
                              title: '',
                              radius: isTouched ? 52 : 46,
                            );
                          }).toList(),
                          // centerSpaceRadius creates the donut hole
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                        ),
                      ),
                      // Center text — TOTAL + amount
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'TOTAL',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            CurrencyFormatter.compact(widget.totalExpenses),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Legend — category name, color, percentage
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.breakdown.take(5).map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Color(item.colorValue),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.categoryName,
                                style: AppTextStyles.bodySecondary.copyWith(
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${item.percentage.toStringAsFixed(0)}%',
                              style: AppTextStyles.bodySecondary.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(item.colorValue),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // ── Category list below chart ──────────────
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Divider(height: 1),
          ),
          ...widget.breakdown.map(
            (item) => _CategoryListItem(
              item: item,
              totalExpenses: widget.totalExpenses,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// Individual category row in the spending list
class _CategoryListItem extends StatelessWidget {
  final CategoryAnalytics item;
  final double totalExpenses;

  const _CategoryListItem({required this.item, required this.totalExpenses});

  @override
  Widget build(BuildContext context) {
    final color = Color(item.colorValue);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              // Circular category icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  IconData(item.iconCode, fontFamily: 'MaterialIcons'),
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              // Category name
              Expanded(
                child: Text(item.categoryName, style: AppTextStyles.cardTitle),
              ),
              // Amount — right aligned
              Text(
                CurrencyFormatter.format(item.amount),
                style: AppTextStyles.cardTitle,
              ),
              const SizedBox(width: 8),
              // Percentage
              SizedBox(
                width: 40,
                child: Text(
                  '${item.percentage.toStringAsFixed(1)}%',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: item.percentage / 100,
              backgroundColor: Theme.of(context).dividerColor,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable empty state for chart cards
class _EmptyChartState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyChartState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary.withOpacity(0.5),
              size: 36,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary,
          ),
        ],
      ),
    );
  }
}
