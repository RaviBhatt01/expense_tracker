import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/expense.dart';

part 'analytics_state.freezed.dart';

// Which time period the user has selected
enum AnalyticsPeriod { week, month, year }

// Holds pre-calculated data for one category's spending
class CategoryAnalytics {
  final String categoryId;
  final String categoryName;
  final double amount;
  final double percentage;
  final int colorValue;

  const CategoryAnalytics({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.percentage,
    required this.colorValue,
  });
}

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
  }) = AnalyticsLoaded;
  const factory AnalyticsState.error({required String message}) =
      AnalyticsError;
}
