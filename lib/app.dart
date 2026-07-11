import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'features/expenses/presentation/cubit/expense_cubit.dart';

class App extends StatelessWidget {
  App({super.key});

  // Create router instance — lives at app level
  // Not inside build() because we don't want it recreated on rebuilds
  final _router = AppRouter();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ExpenseCubit>()..loadExpenses(),
      child: MaterialApp.router(
        title: 'Expense Tracker',
        debugShowCheckedModeBanner: false,
        routerConfig: _router.config(),
      ),
    );
  }
}
