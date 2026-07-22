import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:collection/collection.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/expense.dart';
import '../../domain/usecases/add_budget.dart';
import '../../domain/usecases/delete_budget.dart';
import '../../domain/usecases/get_budgets.dart';
import '../../domain/usecases/get_expenses.dart';
import '../cubit/category_cubit.dart';

part 'budget_state.dart';
part 'budget_cubit.freezed.dart';

class BudgetCubit extends Cubit<BudgetState> {
  final GetBudgetsUseCase _getBudgets;
  final AddBudgetUseCase _addBudget;
  final DeleteBudgetUseCase _deleteBudget;
  final GetExpensesUseCase _getExpenses;
  final CategoryCubit _categoryCubit;

  BudgetCubit({
    required GetBudgetsUseCase getBudgets,
    required AddBudgetUseCase addBudget,
    required DeleteBudgetUseCase deleteBudget,
    required GetExpensesUseCase getExpenses,
    required CategoryCubit categoryCubit,
  }) : _getBudgets = getBudgets,
       _addBudget = addBudget,
       _deleteBudget = deleteBudget,
       _getExpenses = getExpenses,
       _categoryCubit = categoryCubit,
       super(const BudgetState.initial());

  Future<void> loadBudgets() async {
    emit(const BudgetState.loading());

    final results = await Future.wait([
      _getBudgets(NoParams()),
      _getExpenses(
        GetExpensesParams(
          startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
          endDate: DateTime.now(),
        ),
      ),
    ]);

    final budgetResult = results[0] as dynamic;
    final expenseResult = results[1] as dynamic;

    if (budgetResult.isLeft()) {
      budgetResult.fold(
        (failure) => emit(BudgetState.error(message: failure.message)),
        (_) {},
      );
      return;
    }

    if (expenseResult.isLeft()) {
      expenseResult.fold(
        (failure) => emit(BudgetState.error(message: failure.message)),
        (_) {},
      );
      return;
    }

    final budgets = budgetResult.getOrElse(() => <Budget>[]) as List<Budget>;
    final expenses =
        expenseResult.getOrElse(() => <Expense>[]) as List<Expense>;

    _buildBudgetsWithProgress(budgets, expenses);
  }

  void _buildBudgetsWithProgress(List<Budget> budgets, List<Expense> expenses) {
    final budgetsWithProgress = budgets.map((budget) {
      final spent = expenses
          .where(
            (e) =>
                e.categoryId == budget.categoryId &&
                e.type == TransactionType.expense,
          )
          .fold(0.0, (sum, e) => sum + e.amount);

      final percentage = budget.amount > 0
          ? (spent / budget.amount) * 100
          : 0.0;

      final category = _categoryCubit.getCategoryById(budget.categoryId);

      return BudgetWithProgress(
        budget: budget,
        categoryName: category?.name ?? 'General',
        categoryColorValue: category?.colorValue ?? 0xFF6C63FF,
        categoryIcon: category?.icon ?? Icons.category,
        spent: spent,
        percentage: percentage.clamp(0.0, 100.0),
        isOverBudget: spent > budget.amount,
      );
    }).toList();

    emit(BudgetState.loaded(budgets: budgetsWithProgress));
  }

  // Call this when CategoryCubit finishes loading
  // Rebuilds budget progress with correct category details
  void onCategoriesLoaded() {
    final currentState = state;
    if (currentState is! BudgetLoaded) return;

    // Trigger a fresh load to pick up category details
    loadBudgets();
  }

  Future<void> addBudget({
    required String categoryId,
    required double amount,
  }) async {
    // Check if budget already exists for this category
    final currentState = state;
    if (currentState is BudgetLoaded) {
      final exists = currentState.budgets.any(
        (b) => b.budget.categoryId == categoryId,
      );

      if (exists) {
        emit(
          const BudgetState.error(
            message: 'A budget already exists for this category',
          ),
        );
        // Reload to restore state
        await loadBudgets();
        return;
      }
    }

    final budget = Budget(
      id: FirebaseFirestore.instance.collection('budgets').doc().id,
      categoryId: categoryId,
      amount: amount,
      period: BudgetPeriod.monthly, // always monthly
      createdAt: DateTime.now(),
    );

    final result = await _addBudget(budget);

    result.fold(
      (failure) => emit(BudgetState.error(message: failure.message)),
      (_) => loadBudgets(),
    );
  }

  Future<void> updateBudget({
    required String id,
    required double amount,
  }) async {
    final currentState = state;
    if (currentState is! BudgetLoaded) return;

    // Find existing budget
    final existing = currentState.budgets.firstWhereOrNull(
      (b) => b.budget.id == id,
    );

    if (existing == null) return;

    // Create updated budget preserving all other fields
    final updatedBudget = existing.budget.copyWith(amount: amount);

    final result = await _addBudget(updatedBudget);

    result.fold(
      (failure) => emit(BudgetState.error(message: failure.message)),
      (_) => loadBudgets(),
    );
  }

  Future<void> deleteBudget(String id) async {
    final result = await _deleteBudget(id);

    result.fold(
      (failure) => emit(BudgetState.error(message: failure.message)),
      (_) => loadBudgets(),
    );
  }
}
