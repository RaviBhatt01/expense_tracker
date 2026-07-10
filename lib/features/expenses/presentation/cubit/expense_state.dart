import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/expense.dart';

part 'expense_state.freezed.dart';

@freezed
class ExpenseState with _$ExpenseState {
  const factory ExpenseState.initial() = ExpenseInitial;
  const factory ExpenseState.loading() = ExpenseLoading;
  const factory ExpenseState.loaded({
    required List<Expense> expenses,
    @Default(0.0) double totalExpenses,
    @Default(0.0) double totalIncome,
  }) = ExpenseLoaded;
  const factory ExpenseState.error({required String message}) = ExpenseError;
}
