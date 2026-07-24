import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/expense.dart';
import '../../domain/usecases/get_expenses.dart';
import '../cubit/category_cubit.dart';

part 'analytics_state.dart';
part 'analytics_cubit.freezed.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  final GetExpensesUseCase _getExpenses;
  final CategoryCubit _categoryCubit;

  AnalyticsCubit({
    required GetExpensesUseCase getExpenses,
    required CategoryCubit categoryCubit,
  }) : _getExpenses = getExpenses,
       _categoryCubit = categoryCubit,
       super(const AnalyticsState.initial());

  // Add this private field to track current period
  AnalyticsPeriod _currentPeriod = AnalyticsPeriod.month;
  // Expose it as getter
  AnalyticsPeriod get currentPeriod => _currentPeriod;

  Future<void> loadAnalytics({
    AnalyticsPeriod period = AnalyticsPeriod.month,
  }) async {
    // Save current period so auto-reload uses same period
    _currentPeriod = period;

    emit(const AnalyticsState.loading());

    final now = DateTime.now();
    final startDate = _getStartDate(now, period);

    // Fetch expenses for selected period
    final result = await _getExpenses(
      GetExpensesParams(startDate: startDate, endDate: now),
    );

    // Fetch last 6 months of ALL expenses for bar chart
    final sixMonthsAgo = DateTime(now.year, now.month - 5, 1);
    final allRecentResult = await _getExpenses(
      GetExpensesParams(startDate: sixMonthsAgo, endDate: now),
    );

    result.fold(
      (failure) => emit(AnalyticsState.error(message: failure.message)),
      (expenses) {
        allRecentResult.fold(
          (failure) => emit(AnalyticsState.error(message: failure.message)),
          (allRecentExpenses) {
            final totalExpenses = _calculateTotal(
              expenses,
              TransactionType.expense,
            );
            final totalIncome = _calculateTotal(
              expenses,
              TransactionType.income,
            );

            final breakdown = _calculateCategoryBreakdown(
              expenses,
              totalExpenses,
            );

            // Calculate last 6 months comparison
            final monthlyComparisons = _calculateMonthlyComparisons(
              allRecentExpenses,
              now,
            );

            // Calculate last 7 days spending
            final dailySpending = _calculateDailySpending(
              allRecentExpenses,
              now,
            );

            emit(
              AnalyticsState.loaded(
                expenses: expenses,
                totalExpenses: totalExpenses,
                totalIncome: totalIncome,
                categoryBreakdown: breakdown,
                period: period,
                monthlyComparisons: monthlyComparisons,
                dailySpending: dailySpending,
              ),
            );
          },
        );
      },
    );
  }

  // Calculate start date based on selected period
  DateTime _getStartDate(DateTime now, AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.week:
        return now.subtract(const Duration(days: 7));
      case AnalyticsPeriod.month:
        return DateTime(now.year, now.month, 1);
      case AnalyticsPeriod.year:
        return DateTime(now.year, 1, 1);
    }
  }

  double _calculateTotal(List<Expense> expenses, TransactionType type) {
    return expenses
        .where((e) => e.type == type)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  // Group expenses by category and calculate percentage of total
  List<CategoryAnalytics> _calculateCategoryBreakdown(
    List<Expense> expenses,
    double totalExpenses,
  ) {
    if (totalExpenses == 0) return [];

    final expenseOnly = expenses
        .where((e) => e.type == TransactionType.expense)
        .toList();

    final grouped = groupBy(expenseOnly, (e) => e.categoryId);

    final breakdown = grouped.entries.map((entry) {
      final categoryId = entry.key;
      final amount = entry.value.fold(0.0, (sum, e) => sum + e.amount);
      final percentage = (amount / totalExpenses) * 100;
      final category = _categoryCubit.getCategoryById(categoryId);

      return CategoryAnalytics(
        categoryId: categoryId,
        categoryName: category?.name ?? 'General',
        amount: amount,
        percentage: percentage,
        colorValue: category?.colorValue ?? 0xFF6C63FF,
        iconCode: category?.iconCode ?? Icons.category.codePoint,
      );
    }).toList();

    // Sort by amount — highest spending first
    breakdown.sort((a, b) => b.amount.compareTo(a.amount));
    return breakdown;
  }

  // Calculate income vs expense for last 6 months
  List<MonthlyComparison> _calculateMonthlyComparisons(
    List<Expense> expenses,
    DateTime now,
  ) {
    final months = <MonthlyComparison>[];
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    // Build last 6 months in order
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthEnd = DateTime(month.year, month.month + 1, 0);

      final monthExpenses = expenses.where(
        (e) =>
            e.date.isAfter(month.subtract(const Duration(days: 1))) &&
            e.date.isBefore(monthEnd.add(const Duration(days: 1))),
      );

      final income = monthExpenses
          .where((e) => e.type == TransactionType.income)
          .fold(0.0, (sum, e) => sum + e.amount);

      final expense = monthExpenses
          .where((e) => e.type == TransactionType.expense)
          .fold(0.0, (sum, e) => sum + e.amount);

      months.add(
        MonthlyComparison(
          month: monthNames[month.month - 1],
          income: income,
          expense: expense,
        ),
      );
    }

    return months;
  }

  // this method processes already-loaded expenses
  // No Firebase call needed — uses data already in memory
  void processExpenses({
    required List<Expense> allExpenses,
    AnalyticsPeriod? period,
  }) {
    final activePeriod = period ?? _currentPeriod;
    _currentPeriod = activePeriod;

    emit(const AnalyticsState.loading());

    final now = DateTime.now();
    final startDate = _getStartDate(now, activePeriod);

    // Filter expenses for selected period — no Firebase call
    final periodExpenses = allExpenses
        .where(
          (e) =>
              e.date.isAfter(startDate) &&
              e.date.isBefore(now.add(const Duration(days: 1))),
        )
        .toList();

    final totalExpenses = _calculateTotal(
      periodExpenses,
      TransactionType.expense,
    );
    final totalIncome = _calculateTotal(periodExpenses, TransactionType.income);

    final breakdown = _calculateCategoryBreakdown(
      periodExpenses,
      totalExpenses,
    );

    final monthlyComparisons = _calculateMonthlyComparisons(
      allExpenses, // use ALL expenses for 6-month comparison
      now,
    );

    final dailySpending = _calculateDailySpending(allExpenses, now);

    emit(
      AnalyticsState.loaded(
        expenses: periodExpenses,
        totalExpenses: totalExpenses,
        totalIncome: totalIncome,
        categoryBreakdown: breakdown,
        period: activePeriod,
        monthlyComparisons: monthlyComparisons,
        dailySpending: dailySpending,
      ),
    );
  }

  // Calculate daily spending for last 7 days
  List<DailySpending> _calculateDailySpending(
    List<Expense> expenses,
    DateTime now,
  ) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final result = <DailySpending>[];

    // Build last 7 days in order (oldest to newest)
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final dayTotal = expenses
          .where(
            (e) =>
                e.type == TransactionType.expense &&
                e.date.isAfter(dayStart.subtract(const Duration(seconds: 1))) &&
                e.date.isBefore(dayEnd),
          )
          .fold(0.0, (sum, e) => sum + e.amount);

      // weekday: 1=Mon, 7=Sun
      result.add(
        DailySpending(day: dayNames[day.weekday - 1], amount: dayTotal),
      );
    }

    return result;
  }
}
