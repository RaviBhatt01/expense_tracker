import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
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

  // Pending (soft) deletes — keyed by expense id so multiple deletes
  // in flight can each be undone independently within their own window
  final Map<String, Expense> _pendingDeletes = {};
  final Map<String, Timer> _pendingDeleteTimers = {};

  // Current search and filter state
  String _searchQuery = '';
  TransactionType? _filterType;
  Set<String> _filterCategoryIds = {};

  SortOrder _sortOrder = SortOrder.newestFirst;
  DateTimeRange? _dateRange;

  // Expose current filter state for UI to read
  TransactionType? get currentFilterType => _filterType;
  Set<String> get currentFilterCategoryIds => _filterCategoryIds;
  String get currentSearchQuery => _searchQuery;

  // Expose full unfiltered list for export
  List<Expense> get allExpenses => _allExpenses;

  SortOrder get currentSortOrder => _sortOrder;
  DateTimeRange? get currentDateRange => _dateRange;

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
        _allExpenses = expenses;
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

  /// Replace the full set of selected category filters (multi-select)
  void filterByCategories(Set<String> categoryIds) {
    _filterCategoryIds = categoryIds;
    _emitFiltered();
  }

  /// Remove a single category from the active filter (chip "X")
  void removeCategoryFilter(String categoryId) {
    _filterCategoryIds = {..._filterCategoryIds}..remove(categoryId);
    _emitFiltered();
  }

  /// Sort transactions
  void sortBy(SortOrder order) {
    _sortOrder = order;
    _emitFiltered();
  }

  /// Filter by date range
  void filterByDateRange(DateTimeRange? range) {
    _dateRange = range;
    _emitFiltered();
  }

  /// Apply all active filters and search to _allExpenses and emit new state
  void _emitFiltered() {
    var filtered = List<Expense>.from(_allExpenses);

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((e) => e.title.toLowerCase().contains(_searchQuery))
          .toList();
    }

    if (_filterType != null) {
      filtered = filtered.where((e) => e.type == _filterType).toList();
    }

    if (_filterCategoryIds.isNotEmpty) {
      filtered = filtered
          .where((e) => _filterCategoryIds.contains(e.categoryId))
          .toList();
    }

    if (_dateRange != null) {
      filtered = filtered
          .where(
            (e) =>
                e.date.isAfter(
                  _dateRange!.start.subtract(const Duration(days: 1)),
                ) &&
                e.date.isBefore(_dateRange!.end.add(const Duration(days: 1))),
          )
          .toList();
    }

    switch (_sortOrder) {
      case SortOrder.newestFirst:
        filtered.sort((a, b) => b.date.compareTo(a.date));
      case SortOrder.oldestFirst:
        filtered.sort((a, b) => a.date.compareTo(b.date));
      case SortOrder.highestAmount:
        filtered.sort((a, b) => b.amount.compareTo(a.amount));
      case SortOrder.lowestAmount:
        filtered.sort((a, b) => a.amount.compareTo(b.amount));
    }

    emit(
      ExpenseState.loaded(
        expenses: filtered,
        totalExpenses: _calculateTotal(filtered, TransactionType.expense),
        totalIncome: _calculateTotal(filtered, TransactionType.income),
        filterType: _filterType,
        filterCategoryIds: _filterCategoryIds,
        dateRange: _dateRange,
        sortOrder: _sortOrder,
      ),
    );
  }

  /// Clear all filters including date range and sort
  void clearFilters() {
    _searchQuery = '';
    _filterType = null;
    _filterCategoryIds = {};
    _dateRange = null;
    _sortOrder = SortOrder.newestFirst;
    _emitFiltered();
  }

  /// Returns true if any filter or search is active
  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _filterType != null ||
      _filterCategoryIds.isNotEmpty ||
      _dateRange != null ||
      _sortOrder != SortOrder.newestFirst;

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

  /// Soft-deletes immediately (optimistic UI) and schedules the permanent
  /// backend delete 6s later, unless undone before then. Keyed per-id so
  /// multiple in-flight deletes never clash with each other.
  Future<void> deleteExpense(String id) async {
    final expense = _allExpenses.firstWhereOrNull((e) => e.id == id);
    if (expense == null) return;

    // Optimistic update — remove immediately
    _allExpenses = _allExpenses.where((e) => e.id != id).toList();
    _pendingDeletes[id] = expense;
    _emitFiltered();

    _pendingDeleteTimers[id]?.cancel();
    _pendingDeleteTimers[id] = Timer(const Duration(seconds: 6), () async {
      _pendingDeleteTimers.remove(id);
      final pending = _pendingDeletes.remove(id);
      if (pending != null) {
        await _deleteExpense(id);
      }
    });
  }

  void undoDelete(String id) {
    _pendingDeleteTimers.remove(id)?.cancel();

    final expense = _pendingDeletes.remove(id);
    if (expense == null) return;

    _allExpenses = [..._allExpenses, expense]
      ..sort((a, b) => b.date.compareTo(a.date));

    _emitFiltered();
  }

  @override
  Future<void> close() {
    for (final timer in _pendingDeleteTimers.values) {
      timer.cancel();
    }
    return super.close();
  }

  double _calculateTotal(List<Expense> expenses, TransactionType type) {
    return expenses
        .where((e) => e.type == type)
        .fold(0.0, (sum, e) => sum + e.amount);
  }
}