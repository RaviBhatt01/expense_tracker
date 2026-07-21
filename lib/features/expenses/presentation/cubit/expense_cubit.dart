import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/expense.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/delete_expense.dart';
import '../../domain/usecases/get_expenses.dart';
import '../../domain/usecases/update_expense.dart';
import 'expense_state.dart';

@injectable
class ExpenseCubit extends Cubit<ExpenseState> {
  final AddExpenseUseCase _addExpense;
  final GetExpensesUseCase _getExpenses;
  final UpdateExpenseUseCase _updateExpense;
  final DeleteExpenseUseCase _deleteExpense;

  // Full unfiltered list — source of truth for filtering
  List<Expense> _allExpenses = [];

  // Undo delete state
  Expense? _lastDeletedExpense;
  bool _undoRequested = false;

  // Current search and filter state
  String _searchQuery = '';
  TransactionType? _filterType;
  String? _filterCategoryId;

  // Expose current filter state for UI to read
  TransactionType? get currentFilterType => _filterType;
  String? get currentFilterCategoryId => _filterCategoryId;
  String get currentSearchQuery => _searchQuery;

  // Expose full unfiltered list for export
  // Export always exports everything regardless of active filters
  List<Expense> get allExpenses => _allExpenses;

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

  Future<void> loadExpenses() async {
    emit(const ExpenseState.loading());

    final result = await _getExpenses(GetExpensesParams());

    result.fold(
      (failure) => emit(ExpenseState.error(message: failure.message)),
      (expenses) {
        // Store full list
        _allExpenses = expenses;
        // Apply any existing filters
        _emitFiltered();
      },
    );
  }

  /// Search by title — filters in memory, no Firebase call
  void search(String query) {
    _searchQuery = query.toLowerCase().trim();
    _emitFiltered();
  }

  /// Filter by transaction type
  void filterByType(TransactionType? type) {
    _filterType = type;
    _emitFiltered();
  }

  /// Filter by category
  void filterByCategory(String? categoryId) {
    _filterCategoryId = categoryId;
    _emitFiltered();
  }

  /// Clear all search and filters
  void clearFilters() {
    _searchQuery = '';
    _filterType = null;
    _filterCategoryId = null;
    _emitFiltered();
  }

  /// Returns true if any filter or search is active
  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _filterType != null ||
      _filterCategoryId != null;

  /// Apply all active filters and search to _allExpenses
  /// and emit new state
  void _emitFiltered() {
    var filtered = List<Expense>.from(_allExpenses);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((e) => e.title.toLowerCase().contains(_searchQuery))
          .toList();
    }

    // Apply type filter
    if (_filterType != null) {
      filtered = filtered.where((e) => e.type == _filterType).toList();
    }

    // Apply category filter
    if (_filterCategoryId != null) {
      filtered = filtered
          .where((e) => e.categoryId == _filterCategoryId)
          .toList();
    }

    emit(
      ExpenseState.loaded(
        expenses: filtered,
        totalExpenses: _calculateTotal(filtered, TransactionType.expense),
        totalIncome: _calculateTotal(filtered, TransactionType.income),
      ),
    );
  }

  Future<void> addExpense(Expense expense) async {
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
    final currentState = state;
    if (currentState is! ExpenseLoaded) return;

    _lastDeletedExpense = _allExpenses.firstWhereOrNull((e) => e.id == id);
    if (_lastDeletedExpense == null) return;

    // Optimistic update — remove from both lists
    _allExpenses = _allExpenses.where((e) => e.id != id).toList();
    _undoRequested = false;
    _emitFiltered();

    await Future.delayed(const Duration(seconds: 6));

    if (!_undoRequested) {
      await _deleteExpense(id);
      _lastDeletedExpense = null;
    }
  }

  Future<void> undoDelete() async {
    if (_lastDeletedExpense == null) return;

    _undoRequested = true;
    final expenseToRestore = _lastDeletedExpense!;
    _lastDeletedExpense = null;

    // Restore to full list and re-sort
    _allExpenses = [..._allExpenses, expenseToRestore]
      ..sort((a, b) => b.date.compareTo(a.date));

    _emitFiltered();
  }

  double _calculateTotal(List<Expense> expenses, TransactionType type) {
    return expenses
        .where((e) => e.type == type)
        .fold(0.0, (sum, e) => sum + e.amount);
  }
}
