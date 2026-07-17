import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/theme/theme_cubit.dart';
import 'package:expense_tracker/core/di/injection.dart';
import 'package:expense_tracker/core/router/app_router.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/get_expenses.dart';
import 'package:expense_tracker/features/expenses/presentation/cubit/analytics_cubit.dart';
import 'package:expense_tracker/features/expenses/presentation/cubit/category_cubit.dart';
import 'package:expense_tracker/features/expenses/presentation/cubit/expense_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/expenses/domain/usecases/add_budget.dart';
import 'features/expenses/domain/usecases/delete_budget.dart';
import 'features/expenses/domain/usecases/get_budgets.dart';
import 'features/expenses/presentation/cubit/budget_cubit.dart';

class App extends StatelessWidget {
  App({super.key});

  final _router = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Theme cubit — controls dark/light mode
        BlocProvider(create: (context) => ThemeCubit()),
        BlocProvider(
          lazy: false,
          create: (context) => getIt<CategoryCubit>()..initializeCategories(),
        ),
        BlocProvider(
          lazy: false,
          create: (context) => getIt<ExpenseCubit>()..loadExpenses(),
        ),
        BlocProvider(
          create: (context) => AnalyticsCubit(
            getExpenses: getIt<GetExpensesUseCase>(),
            categoryCubit: context.read<CategoryCubit>(),
          ),
        ),
        BlocProvider(
          lazy: false,
          create: (context) => BudgetCubit(
            getBudgets: getIt<GetBudgetsUseCase>(),
            addBudget: getIt<AddBudgetUseCase>(),
            deleteBudget: getIt<DeleteBudgetUseCase>(),
            getExpenses: getIt<GetExpensesUseCase>(),
            categoryCubit: context.read<CategoryCubit>(),
          )..loadBudgets(),
        ),
      ],
      // BlocBuilder listens to ThemeCubit
      // Rebuilds MaterialApp when theme changes
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'SpendWise',
            debugShowCheckedModeBanner: false,
            // Apply correct theme based on cubit state
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            routerConfig: _router.config(),
          );
        },
      ),
    );
  }
}
