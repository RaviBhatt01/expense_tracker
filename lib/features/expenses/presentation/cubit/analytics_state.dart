part of 'analytics_cubit.dart';

// Holds income vs expense data for one month
// Used in the grouped bar chart
class MonthlyComparison {
  final String month; // e.g. "Jan", "Feb"
  final double income;
  final double expense;

  const MonthlyComparison({
    required this.month,
    required this.income,
    required this.expense,
  });
}

// Holds spending data for one day
// Used in the weekly trend line chart
class DailySpending {
  final String day; // e.g. "Mon", "Tue"
  final double amount;

  const DailySpending({required this.day, required this.amount});
}

// Holds pre-calculated data for one category's spending
class CategoryAnalytics {
  final String categoryId;
  final String categoryName;
  final double amount;
  final double percentage;
  final int colorValue;
  final int iconCode;

  const CategoryAnalytics({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.percentage,
    required this.colorValue,
    required this.iconCode,
  });
}

enum AnalyticsPeriod { week, month, year }

@freezed
class AnalyticsState with _$AnalyticsState {
  const factory AnalyticsState.initial() = AnalyticsInitial;
  const factory AnalyticsState.loading() = AnalyticsLoading;
  const factory AnalyticsState.loaded({
    required List<Expense> expenses,
    required double totalExpenses,
    required double totalIncome,
    required List<CategoryAnalytics> categoryBreakdown,
    required AnalyticsPeriod period,
    // Last 6 months income vs expense data
    required List<MonthlyComparison> monthlyComparisons,
    // Last 7 days daily spending
    required List<DailySpending> dailySpending,
  }) = AnalyticsLoaded;
  const factory AnalyticsState.error({required String message}) =
      AnalyticsError;
}
