import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // AutoRouter renders the active nested route
    // Either TransactionsListPage or TransactionDetailPage
    return const AutoRouter();
  }
}
