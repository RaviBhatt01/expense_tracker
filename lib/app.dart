import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'features/expenses/presentation/cubit/category_cubit.dart';
import 'features/expenses/presentation/cubit/expense_cubit.dart';

class App extends StatelessWidget {
  App({super.key});

  // Create router instance — lives at app level
  // Not inside build() because we don't want it recreated on rebuilds
  final _router = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          // lazy: false — create immediately without waiting
          // for a widget to request it. Needed because seeding
          // must happen at app start before any screen loads.
          lazy: false,
          create: (context) {
            final cubit = getIt<CategoryCubit>();
            cubit.initializeCategories();
            return cubit;
          },
        ),
        BlocProvider(
          lazy: false,
          create: (context) => getIt<ExpenseCubit>()..loadExpenses(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Expense Tracker',
        debugShowCheckedModeBanner: false,
        routerConfig: _router.config(),
      ),
    );
  }
}
