// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AddExpensePage]
class AddExpenseRoute extends PageRouteInfo<AddExpenseRouteArgs> {
  AddExpenseRoute({Key? key, Expense? expense, List<PageRouteInfo>? children})
    : super(
        AddExpenseRoute.name,
        args: AddExpenseRouteArgs(key: key, expense: expense),
        initialChildren: children,
      );

  static const String name = 'AddExpenseRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddExpenseRouteArgs>(
        orElse: () => const AddExpenseRouteArgs(),
      );
      return AddExpensePage(key: args.key, expense: args.expense);
    },
  );
}

class AddExpenseRouteArgs {
  const AddExpenseRouteArgs({this.key, this.expense});

  final Key? key;

  final Expense? expense;

  @override
  String toString() {
    return 'AddExpenseRouteArgs{key: $key, expense: $expense}';
  }
}

/// generated route for
/// [AnalyticsPage]
class AnalyticsRoute extends PageRouteInfo<void> {
  const AnalyticsRoute({List<PageRouteInfo>? children})
    : super(AnalyticsRoute.name, initialChildren: children);

  static const String name = 'AnalyticsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AnalyticsPage();
    },
  );
}

/// generated route for
/// [BudgetsPage]
class BudgetsRoute extends PageRouteInfo<void> {
  const BudgetsRoute({List<PageRouteInfo>? children})
    : super(BudgetsRoute.name, initialChildren: children);

  static const String name = 'BudgetsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const BudgetsPage();
    },
  );
}

/// generated route for
/// [CategoryManagementPage]
class CategoryManagementRoute extends PageRouteInfo<void> {
  const CategoryManagementRoute({List<PageRouteInfo>? children})
    : super(CategoryManagementRoute.name, initialChildren: children);

  static const String name = 'CategoryManagementRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CategoryManagementPage();
    },
  );
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomePage();
    },
  );
}

/// generated route for
/// [MainPage]
class MainRoute extends PageRouteInfo<void> {
  const MainRoute({List<PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainPage();
    },
  );
}

/// generated route for
/// [SettingsPage]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsPage();
    },
  );
}

/// generated route for
/// [TransactionDetailPage]
class TransactionDetailRoute extends PageRouteInfo<TransactionDetailRouteArgs> {
  TransactionDetailRoute({
    Key? key,
    required Expense expense,
    List<PageRouteInfo>? children,
  }) : super(
         TransactionDetailRoute.name,
         args: TransactionDetailRouteArgs(key: key, expense: expense),
         initialChildren: children,
       );

  static const String name = 'TransactionDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TransactionDetailRouteArgs>();
      return TransactionDetailPage(key: args.key, expense: args.expense);
    },
  );
}

class TransactionDetailRouteArgs {
  const TransactionDetailRouteArgs({this.key, required this.expense});

  final Key? key;

  final Expense expense;

  @override
  String toString() {
    return 'TransactionDetailRouteArgs{key: $key, expense: $expense}';
  }
}

/// generated route for
/// [TransactionsListPage]
class TransactionsListRoute extends PageRouteInfo<void> {
  const TransactionsListRoute({List<PageRouteInfo>? children})
    : super(TransactionsListRoute.name, initialChildren: children);

  static const String name = 'TransactionsListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TransactionsListPage();
    },
  );
}

/// generated route for
/// [TransactionsPage]
class TransactionsRoute extends PageRouteInfo<void> {
  const TransactionsRoute({List<PageRouteInfo>? children})
    : super(TransactionsRoute.name, initialChildren: children);

  static const String name = 'TransactionsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TransactionsPage();
    },
  );
}
