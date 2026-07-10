import 'package:auto_route/auto_route.dart';

import '../../features/expenses/presentation/pages/add_expense_page.dart';
import '../../features/expenses/presentation/pages/home_page.dart';
import '../../features/expenses/presentation/pages/transactions_page.dart';

// This annotation triggers auto_route code generation
// It generates AppRouter class with all navigation logic
part 'app_router.gr.dart';

@AutoRouterConfig(generateForDir: ['lib'])
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    // initial: true means this is the first screen shown
    AutoRoute(page: HomeRoute.page, initial: true),
    AutoRoute(page: TransactionsRoute.page),
    AutoRoute(page: AddExpenseRoute.page),
  ];
}
