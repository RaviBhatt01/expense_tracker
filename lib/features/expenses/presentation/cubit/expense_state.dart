import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/expense.dart';

part 'expense_state.freezed.dart';

enum SortOrder { newestFirst, oldestFirst, highestAmount, lowestAmount }

@freezed
class ExpenseState with _$ExpenseState {
  const factory ExpenseState.initial() = ExpenseInitial;
  const factory ExpenseState.loading() = ExpenseLoading;
  const factory ExpenseState.loaded({
    required List<Expense> expenses,
    @Default(0.0) double totalExpenses,
    @Default(0.0) double totalIncome,
    TransactionType? filterType,
    String? filterCategoryId,
    DateTimeRange? dateRange,
    @Default(SortOrder.newestFirst) SortOrder sortOrder,
  }) = ExpenseLoaded;
  const factory ExpenseState.error({required String message}) = ExpenseError;
}
