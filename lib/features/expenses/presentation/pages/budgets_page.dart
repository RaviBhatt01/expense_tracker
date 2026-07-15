import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

@RoutePage()
class BudgetsPage extends StatelessWidget {
  const BudgetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text('Budgets', style: AppTextStyles.sectionTitle),
      ),
      body: const Center(
        child: Text('Budgets coming soon', style: AppTextStyles.cardTitle),
      ),
    );
  }
}
