import 'package:flutter/material.dart';
import 'core/router/app_router.dart';

class App extends StatelessWidget {
  App({super.key});

  // Create router instance — lives at app level
  // Not inside build() because we don't want it recreated on rebuilds
  final _router = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      routerConfig: _router.config(),
    );
  }
}
