import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/expense.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/get_expenses.dart';
import '../../domain/usecases/update_expense.dart';
import '../../domain/usecases/delete_expense.dart';
import 'expense_state.dart';

@injectable
class ExpenseCubit extends Cubit<ExpenseState> {
  final AddExpenseUseCase _addExpense;
  final GetExpensesUseCase _getExpenses;
  final UpdateExpenseUseCase _updateExpense;
  final DeleteExpenseUseCase _deleteExpense;

  ExpenseCubit({
    required AddExpenseUseCase addExpense,
    required GetExpensesUseCase getExpenses,
    required UpdateExpenseUseCase updateExpense,
    required DeleteExpenseUseCase deleteExpense,
  }) : _addExpense = addExpense,
       _getExpenses = getExpenses,
       _updateExpense = updateExpense,
       _deleteExpense = deleteExpense,
       super(const ExpenseState.initial());

  Future<void> loadExpenses({
    TransactionType? type,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    emit(const ExpenseState.loading());

    final result = await _getExpenses(
      GetExpensesParams(
        type: type,
        categoryId: categoryId,
        startDate: startDate,
        endDate: endDate,
      ),
    );

    result.fold(
      (failure) => emit(ExpenseState.error(message: failure.message)),
      (expenses) => emit(
        ExpenseState.loaded(
          expenses: expenses,
          totalExpenses: _calculateTotal(expenses, TransactionType.expense),
          totalIncome: _calculateTotal(expenses, TransactionType.income),
        ),
      ),
    );
  }

  Future<void> addExpense(Expense expense) async {
    // Keep everything the form gave us, just add id and createdAt
    final newExpense = expense.copyWith(
      id: FirebaseFirestore.instance.collection('expenses').doc().id,
      createdAt: DateTime.now(),
    );

    final result = await _addExpense(newExpense);

    result.fold(
      (failure) => emit(ExpenseState.error(message: failure.message)),
      (_) => loadExpenses(),
    );
  }

  Future<void> updateExpense(Expense expense) async {
    final result = await _updateExpense(expense);

    result.fold(
      (failure) => emit(ExpenseState.error(message: failure.message)),
      (_) => loadExpenses(),
    );
  }

  Future<void> deleteExpense(String id) async {
    final result = await _deleteExpense(id);

    result.fold(
      (failure) => emit(ExpenseState.error(message: failure.message)),
      (_) => loadExpenses(),
    );
  }

  double _calculateTotal(List<Expense> expenses, TransactionType type) {
    return expenses
        .where((e) => e.type == type)
        .fold(0.0, (sum, e) => sum + e.amount);
  }
}
