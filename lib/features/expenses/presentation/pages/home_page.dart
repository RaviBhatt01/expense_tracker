import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../cubit/expense_cubit.dart';
import '../cubit/expense_state.dart';
import '../widgets/expense_summary_card.dart';
import '../widgets/recent_transactions_list.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Create cubit from DI and immediately load expenses
      create: (context) => getIt<ExpenseCubit>()..loadExpenses(),
      child: const _HomeView(),
    );
  }
}

// Separated into private widget so BlocBuilder can access the cubit
// BlocProvider must be ABOVE BlocBuilder in the widget tree
class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
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
                    // Summary cards
                    SliverToBoxAdapter(
                      child: ExpenseSummaryCard(
                        totalIncome: totalIncome,
                        totalExpenses: totalExpenses,
                      ),
                    ),
                    // Recent transactions header
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                        child: Text(
                          'Recent Transactions',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Recent transactions list — show last 5 only
                    RecentTransactionsList(expenses: expenses.take(5).toList()),
                  ],
                );
              },
              error: (message) => Center(
                child: Text(message, style: const TextStyle(color: Colors.red)),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.router.push(const AddExpenseRoute()),
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// Header widget — greeting and balance display
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
          const Text(
            'Good morning 👋',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your Balance',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'NPR ${balance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
