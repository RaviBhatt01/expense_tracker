import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../features/expenses/domain/entities/expense.dart';
import '../../features/expenses/presentation/pages/add_expense_page.dart';
import '../../features/expenses/presentation/pages/category_management_page.dart';
import '../../features/expenses/presentation/pages/home_page.dart';
import '../../features/expenses/presentation/pages/transactions_page.dart';
import '../../features/expenses/presentation/pages/transactions_list_page.dart';
import '../../features/expenses/presentation/pages/transaction_detail_page.dart';
import '../../features/expenses/presentation/pages/main_page.dart';
import '../../features/expenses/presentation/pages/analytics_page.dart';
import '../../features/expenses/presentation/pages/budgets_page.dart';
import '../../features/expenses/presentation/pages/settings_page.dart';
import '../../features/onboarding/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';

// This annotation triggers auto_route code generation
// It generates AppRouter class with all navigation logic
part 'app_router.gr.dart';

@AutoRouterConfig(generateForDir: ['lib'])
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    // Splash is the first screen — initial: true
    AutoRoute(page: SplashRoute.page, initial: true),
    AutoRoute(page: OnboardingRoute.page),
    AutoRoute(
      page: MainRoute.page,
      // These are the nested tab routes inside MainPage
      children: [
        AutoRoute(page: HomeRoute.page, initial: true),
        AutoRoute(
          page: TransactionsRoute.page,
          maintainState: false,
          children: [
            AutoRoute(page: TransactionsListRoute.page, initial: true),
            AutoRoute(page: TransactionDetailRoute.page),
          ],
        ),
        AutoRoute(page: AnalyticsRoute.page),
        AutoRoute(page: BudgetsRoute.page),
        AutoRoute(page: SettingsRoute.page),
      ],
    ),
    AutoRoute(page: AddExpenseRoute.page),
    AutoRoute(page: CategoryManagementRoute.page),
  ];
}
