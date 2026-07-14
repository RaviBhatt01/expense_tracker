import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/expense.dart';
import '../../domain/usecases/get_expenses.dart';
import '../cubit/category_cubit.dart';
import 'analytics_state.dart'; // ← import, not part

// Remove @injectable — we create this manually in app.dart
class AnalyticsCubit extends Cubit<AnalyticsState> {
  final GetExpensesUseCase _getExpenses;
  final CategoryCubit _categoryCubit;

  AnalyticsCubit({
    required GetExpensesUseCase getExpenses,
    required CategoryCubit categoryCubit,
  }) : _getExpenses = getExpenses,
       _categoryCubit = categoryCubit,
       super(const AnalyticsState.initial());

  Future<void> loadAnalytics({
    AnalyticsPeriod period = AnalyticsPeriod.month,
  }) async {
    emit(const AnalyticsState.loading());

    final now = DateTime.now();
    final startDate = _getStartDate(now, period);

    final result = await _getExpenses(
      GetExpensesParams(startDate: startDate, endDate: now),
    );

    result.fold(
      (failure) => emit(AnalyticsState.error(message: failure.message)),
      (expenses) {
        final totalExpenses = _calculateTotal(
          expenses,
          TransactionType.expense,
        );
        final totalIncome = _calculateTotal(expenses, TransactionType.income);

        final breakdown = _calculateCategoryBreakdown(expenses, totalExpenses);

        emit(
          AnalyticsState.loaded(
            expenses: expenses,
            totalExpenses: totalExpenses,
            totalIncome: totalIncome,
            categoryBreakdown: breakdown,
            period: period,
          ),
        );
      },
    );
  }

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
      );
    }).toList();

    breakdown.sort((a, b) => b.amount.compareTo(a.amount));
    return breakdown;
  }
}
