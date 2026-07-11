import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/expense_cubit.dart';
import '../cubit/expense_state.dart';
import '../widgets/expense_summary_card.dart';
import '../widgets/recent_transactions_list.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Cubit comes from app level — no BlocProvider needed here
    return const _HomeView();
  }
}

// Separated into private widget so BlocBuilder can access the cubit
// BlocProvider must be ABOVE BlocBuilder in the widget tree
class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<ExpenseCubit, ExpenseState>(
          builder: (context, state) {
            return state.when(
              initial: () => const SizedBox(),
              loading: () => const Center(child: CircularProgressIndicator()),
              loaded: (expenses, totalExpenses, totalIncome) {
                final balance = totalIncome - totalExpenses;
                return CustomScrollView(
                  slivers: [
                    // Header section
                    SliverToBoxAdapter(child: _Header(balance: balance)),
                    // Income and expense summary cards
                    SliverToBoxAdapter(
                      child: ExpenseSummaryCard(
                        totalIncome: totalIncome,
                        totalExpenses: totalExpenses,
                      ),
                    ),
                    // Recent transactions section label
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                        child: Text(
                          'Recent Transactions',
                          style: AppTextStyles.sectionTitle,
                        ),
                      ),
                    ),
                    // Show only last 5 transactions on home screen
                    RecentTransactionsList(expenses: expenses.take(5).toList()),
                  ],
                );
              },
              error: (message) => Center(
                child: Text(
                  message,
                  style: const TextStyle(color: AppColors.expense),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.router.push(const AddExpenseRoute()),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.iconOnColor),
      ),
    );
  }
}

// Header showing greeting and current balance
class _Header extends StatelessWidget {
  final double balance;

  const _Header({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Good morning 👋', style: AppTextStyles.greeting),
          const SizedBox(height: 8),
          const Text('Your Balance', style: AppTextStyles.label),
          const SizedBox(height: 4),
          Text(
            'NPR ${balance.toStringAsFixed(2)}',
            style: AppTextStyles.balanceAmount,
          ),
        ],
      ),
    );
  }
}
