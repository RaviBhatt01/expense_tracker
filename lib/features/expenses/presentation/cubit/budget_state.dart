part of 'budget_cubit.dart';

// Holds a budget with all pre-calculated display data
class BudgetWithProgress {
  final Budget budget;
  final String categoryName;
  final int categoryColorValue;
  final IconData categoryIcon;

  // How much has been spent in this category this period
  final double spent;

  // What percentage of budget is used (0-100, clamped)
  final double percentage;

  // True when spending exceeds the budget limit
  final bool isOverBudget;

  const BudgetWithProgress({
    required this.budget,
    required this.categoryName,
    required this.categoryColorValue,
    required this.categoryIcon,
    required this.spent,
    required this.percentage,
    required this.isOverBudget,
  });
}

@freezed
class BudgetState with _$BudgetState {
  const factory BudgetState.initial() = BudgetInitial;
  const factory BudgetState.loading() = BudgetLoading;
  const factory BudgetState.loaded({
    required List<BudgetWithProgress> budgets,
  }) = BudgetLoaded;
  const factory BudgetState.error({required String message}) = BudgetError;
}
