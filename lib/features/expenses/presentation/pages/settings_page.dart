import 'package:auto_route/auto_route.dart';
import 'package:expense_tracker/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../core/utils/csv_exporter.dart';
import '../cubit/category_cubit.dart';
import '../cubit/expense_cubit.dart';
import '../cubit/expense_state.dart';

@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings', style: AppTextStyles.sectionTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          // ── Profile Card ─────────────────────────────
          // Placeholder for when Auth is added
          _ProfileCard(),
          const SizedBox(height: 28),

          // ── Appearance Section ───────────────────────
          const _SectionHeader(title: 'Appearance'),
          const SizedBox(height: 12),
          _ThemeToggleTile(),
          const SizedBox(height: 28),

          // ── Preferences Section ──────────────────────
          const _SectionHeader(title: 'Preferences'),
          const SizedBox(height: 12),
          _SettingsGroup(
            children: [
              _SettingsTile(
                icon: Icons.attach_money_rounded,
                iconColor: AppColors.income,
                title: 'Currency',
                subtitle: AppConstants.currency,
                onTap: () {
                  // TODO: currency picker in future session
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Coming soon')));
                },
              ),
              _SettingsDivider(),
              _SettingsTile(
                icon: Icons.category_outlined,
                iconColor: AppColors.primary,
                title: 'Manage Categories',
                subtitle: 'Add or remove custom categories',
                onTap: () =>
                    context.router.push(const CategoryManagementRoute()),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // ── Data Section ─────────────────────────────
          const _SectionHeader(title: 'Data'),
          const SizedBox(height: 12),
          _SettingsGroup(
            children: [
              _SettingsTile(
                icon: Icons.file_download_outlined,
                iconColor: const Color(0xFF06B6D4),
                title: 'Export Transactions',
                subtitle: 'Download all transactions as CSV',
                onTap: () => _exportData(context),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // ── About Section ────────────────────────────
          const _SectionHeader(title: 'About'),
          const SizedBox(height: 12),
          _SettingsGroup(
            children: [
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                iconColor: AppColors.primaryLight,
                title: 'App Version',
                subtitle: '1.0.0 (Beta)',
                showChevron: false,
                onTap: () {},
              ),
              _SettingsDivider(),
              _SettingsTile(
                icon: Icons.flutter_dash_rounded,
                iconColor: const Color(0xFF06B6D4),
                title: 'Built with',
                subtitle: 'Flutter + Firebase + Clean Architecture',
                showChevron: false,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 40),

          // ── App Signature ─────────────────────────────
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'SpendWise',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Made with ❤️ in Flutter',
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _exportData(BuildContext context) async {
    final expenseState = context.read<ExpenseCubit>().state;
    final categoryState = context.read<CategoryCubit>().state;

    // Check both states are loaded
    if (expenseState is! ExpenseLoaded || categoryState is! CategoryLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait for data to load')),
      );
      return;
    }

    // Get ALL expenses — export always exports everything
    // regardless of any active filters
    final expenses = context.read<ExpenseCubit>().allExpenses;
    final categories = categoryState.categories;

    if (expenses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No transactions to export')),
      );
      return;
    }

    try {
      await CsvExporter.export(expenses: expenses, categories: categories);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }
}

// Profile card — placeholder until Auth is added
class _ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Gradient background for premium feel
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Avatar placeholder
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Sign in to sync across devices',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Sign in button — will wire up with Auth
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Sign In',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Section header
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.label.copyWith(
          color: AppColors.primary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

// Groups multiple tiles into one rounded card
// Much cleaner than individual cards per tile
class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

// Thin divider between tiles in a group
class _SettingsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 56,
      endIndent: 16,
      color: Theme.of(context).dividerColor,
    );
  }
}

// Theme toggle tile — switches dark/light
class _ThemeToggleTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDark = themeMode == ThemeMode.dark;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Animated icon container
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E1B4B).withOpacity(0.6)
                      : const Color(0xFFFEF9C3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    // Dark = indigo icon, Light = amber icon
                    color: isDark
                        ? const Color(0xFF818CF8)
                        : const Color(0xFFF59E0B),
                    size: 20,
                    key: ValueKey(isDark),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Appearance', style: AppTextStyles.cardTitle),
                    Text(
                      isDark ? 'Dark mode is on' : 'Light mode is on',
                      style: AppTextStyles.bodySecondary,
                    ),
                  ],
                ),
              ),
              // Custom styled switch
              Switch(
                value: isDark,
                onChanged: (_) => context.read<ThemeCubit>().toggle(),
                activeColor: AppColors.primary,
                activeTrackColor: AppColors.primary.withOpacity(0.3),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Reusable settings tile — fits inside _SettingsGroup
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showChevron;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Icon with colored rounded background
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.cardTitle),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.bodySecondary),
                  ],
                ),
              ),
              if (showChevron)
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
