import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

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

    // Fetch budgets and current month expenses in parallel
    // Future.wait runs both simultaneously — faster than sequential
    final results = await Future.wait([
      _getBudgets(NoParams()),
      _getExpenses(
        GetExpensesParams(
          // Only look at current month expenses for budget progress
          startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
          endDate: DateTime.now(),
        ),
      ),
    ]);

    final budgetResult = results[0] as dynamic;
    final expenseResult = results[1] as dynamic;

    // If either fails return error
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

    // Calculate progress for each budget
    final budgetsWithProgress = budgets.map((budget) {
      // Sum expenses for this category this month
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

      // Look up category details
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

  Future<void> addBudget({
    required String categoryId,
    required double amount,
    required BudgetPeriod period,
  }) async {
    final budget = Budget(
      // Generate unique ID locally
      id: FirebaseFirestore.instance.collection('budgets').doc().id,
      categoryId: categoryId,
      amount: amount,
      period: period,
      createdAt: DateTime.now(),
    );

    final result = await _addBudget(budget);

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
