import 'package:auto_route/auto_route.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../cubit/analytics_cubit.dart';
import '../cubit/category_cubit.dart';
import '../cubit/expense_cubit.dart';
import '../cubit/expense_state.dart';
import '../widgets/budget_alert_card.dart';
import '../widgets/recent_transactions_list.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Cubit comes from app level — no BlocProvider needed here
    return const _HomeView();
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocBuilder<ExpenseCubit, ExpenseState>(
          builder: (context, expenseState) {
            return expenseState.when(
              initial: () => const SizedBox(),
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              loaded: (expenses, totalExpenses, totalIncome, filterType, filterCategoryId, dateRange, sortOrder) {
                final balance = totalIncome - totalExpenses;

                return BlocBuilder<CategoryCubit, CategoryState>(
                  builder: (context, categoryState) {
                    // Wait for categories to load before rendering
                    // This ensures category icons show correctly on first render
                    if (categoryState is! CategoryLoaded) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    return CustomScrollView(
                      slivers: [
                        // ── App Bar ──────────────────────────
                        SliverToBoxAdapter(child: _HomeAppBar()),

                        // ── Balance + Summary Card ────────────
                        SliverToBoxAdapter(
                          child: _BalanceSummaryCard(
                            balance: balance,
                            totalIncome: totalIncome,
                            totalExpenses: totalExpenses,
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 16)),

                        // ── Budget Alerts ────────────────────
                        const SliverToBoxAdapter(child: BudgetAlertCard()),

                        // ── Weekly Spending Chart ─────────────
                        SliverToBoxAdapter(child: _WeeklySpendingCard()),
                        const SliverToBoxAdapter(child: SizedBox(height: 16)),

                        // ── Recent Transactions ───────────────
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
                            child: Row(
                              children: [
                                const Text(
                                  'Recent Transactions',
                                  style: AppTextStyles.sectionTitle,
                                ),
                                const Spacer(),
                                // Navigate by switching tab — not pushing
                                // Pushing would stack transactions on home tab
                                TextButton(
                                  onPressed: () => AutoTabsRouter.of(
                                    context,
                                  ).setActiveIndex(1),
                                  child: Text(
                                    'See All',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        RecentTransactionsList(
                          expenses: expenses.take(5).toList(),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 100)),
                      ],
                    );
                  },
                );
              },
              error: (message) => Center(
                child: Text(
                  message,
                  style: const TextStyle(color: AppColors.expense),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'home_fab',
        onPressed: () => context.router.push(AddExpenseRoute()),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.iconOnColor),
      ),
    );
  }
}

// Custom app bar with profile, greeting, notification and menu
class _HomeAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Determine greeting based on time of day
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
        ? 'Good afternoon'
        : 'Good evening';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Row(
        children: [
          // ── Avatar ─────────────────────────────────
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // ── Greeting + Name ─────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$greeting 👋', style: AppTextStyles.bodySecondary),
                const Text(
                  'SpendWise', // will be replaced with user name after Auth
                  style: AppTextStyles.cardTitle,
                ),
              ],
            ),
          ),

          // ── Notification Icon ────────────────────────
          // No navigation for now — placeholder for future
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              // Notification dot
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.expense,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),

          // ── Dot Menu ────────────────────────────────
          // Placeholder for future actions
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {},
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ],
      ),
    );
  }
}

// Combined balance + income/expense summary in one card
class _BalanceSummaryCard extends StatelessWidget {
  final double balance;
  final double totalIncome;
  final double totalExpenses;

  const _BalanceSummaryCard({
    required this.balance,
    required this.totalIncome,
    required this.totalExpenses,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        // Gradient background for premium feel
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Total Balance ──────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Total Balance',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    // Balance positive/negative indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            balance >= 0
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            balance >= 0 ? 'Positive' : 'Negative',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  CurrencyFormatter.format(balance, showDecimals: true),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          // ── Divider ────────────────────────────────
          Container(height: 1, color: Colors.white.withOpacity(0.15)),

          // ── Income / Expense row ───────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: _BalanceSummaryItem(
                    icon: Icons.arrow_downward_rounded,
                    label: 'Income',
                    amount: totalIncome,
                    iconBackground: AppColors.income.withOpacity(0.2),
                    iconColor: AppColors.income,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.15),
                ),
                Expanded(
                  child: _BalanceSummaryItem(
                    icon: Icons.arrow_upward_rounded,
                    label: 'Expenses',
                    amount: totalExpenses,
                    iconBackground: AppColors.expense.withOpacity(0.2),
                    iconColor: AppColors.expense,
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

class _BalanceSummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color iconBackground;
  final Color iconColor;

  const _BalanceSummaryItem({
    required this.icon,
    required this.label,
    required this.amount,
    required this.iconBackground,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              CurrencyFormatter.compact(amount),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Weekly spending trend card — same chart as analytics
// Uses AnalyticsCubit data already loaded at app level
class _WeeklySpendingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsCubit, AnalyticsState>(
      builder: (context, state) {
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
              // ── Card header ──────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Spending This Week',
                            style: AppTextStyles.sectionTitle,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Last 7 days',
                            style: AppTextStyles.bodySecondary,
                          ),
                        ],
                      ),
                    ),
                    // See all — switches to Analytics tab
                    // Using setActiveIndex avoids stacking screens
                    TextButton(
                      onPressed: () =>
                          AutoTabsRouter.of(context).setActiveIndex(2),
                      child: Text(
                        'See All',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Chart or empty state ──────────────────
              state.maybeWhen(
                loaded:
                    (
                      _,
                      __,
                      ___,
                      ____,
                      _____,
                      monthlyComparisons,
                      dailySpending,
                    ) {
                      final hasData = dailySpending.any((d) => d.amount > 0);

                      if (!hasData) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 28),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.show_chart_rounded,
                                  color: AppColors.primary.withOpacity(0.3),
                                  size: 40,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'No spending this week',
                                  style: AppTextStyles.bodySecondary,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
                        child: SizedBox(
                          height: 150,
                          child: _MiniLineChart(dailySpending: dailySpending),
                        ),
                      );
                    },
                orElse: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
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

// Mini line chart for home screen weekly spending
class _MiniLineChart extends StatelessWidget {
  final List<DailySpending> dailySpending;

  const _MiniLineChart({required this.dailySpending});

  @override
  Widget build(BuildContext context) {
    final maxAmount = dailySpending.fold<double>(
      0,
      (max, d) => d.amount > max ? d.amount : max,
    );

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxAmount * 1.3,
        // Disable touch on home screen — full interactivity in analytics
        lineTouchData: const LineTouchData(enabled: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Theme.of(context).dividerColor,
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        titlesData: FlTitlesData(
          // Day labels on bottom
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= dailySpending.length) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    dailySpending[index].day,
                    style: AppTextStyles.bodySecondary.copyWith(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          // No Y axis labels on mini chart — keeps it clean
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
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
            spots: dailySpending
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.amount))
                .toList(),
            isCurved: true,
            curveSmoothness: 0.35,
            color: AppColors.primary,
            barWidth: 2.5,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withOpacity(0.25),
                  AppColors.primary.withOpacity(0.0),
                ],
              ),
            ),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 3,
                color: Theme.of(context).cardColor,
                strokeWidth: 2,
                strokeColor: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }
}
