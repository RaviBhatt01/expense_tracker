import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget.freezed.dart';

// Which period this budget covers
enum BudgetPeriod { weekly, monthly, yearly }

@freezed
class Budget with _$Budget {
  const factory Budget({
    required String id,
    required String categoryId,

    // The spending limit set by user
    required double amount,

    // Period this budget applies to
    required BudgetPeriod period,

    // When this budget was created
    required DateTime createdAt,
  }) = _Budget;
}
