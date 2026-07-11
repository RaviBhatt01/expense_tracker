import 'package:auto_route/auto_route.dart';

import '../../features/expenses/presentation/pages/add_expense_page.dart';
import '../../features/expenses/presentation/pages/home_page.dart';
import '../../features/expenses/presentation/pages/transactions_page.dart';
import '../../features/expenses/presentation/pages/main_page.dart';
import '../../features/expenses/presentation/pages/analytics_page.dart';
import '../../features/expenses/presentation/pages/budgets_page.dart';
import '../../features/expenses/presentation/pages/settings_page.dart';

// This annotation triggers auto_route code generation
// It generates AppRouter class with all navigation logic
part 'app_router.gr.dart';

@AutoRouterConfig(generateForDir: ['lib'])
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    // MainPage wraps all tab routes
    AutoRoute(
      page: MainRoute.page,
      initial: true,
      // These are the nested tab routes inside MainPage
      children: [
        AutoRoute(page: HomeRoute.page, initial: true),
        AutoRoute(page: TransactionsRoute.page),
        AutoRoute(page: AnalyticsRoute.page),
        AutoRoute(page: BudgetsRoute.page),
        AutoRoute(page: SettingsRoute.page),
      ],
    ),
    // AddExpense is outside tabs — it pushes on top of everything
    AutoRoute(page: AddExpenseRoute.page),
  ];
}
