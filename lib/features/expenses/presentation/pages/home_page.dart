import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

// @RoutePage() tells auto_route this is a navigatable screen
@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expense Tracker')),
      body: const Center(child: Text('Home Page')),
    );
  }
}
