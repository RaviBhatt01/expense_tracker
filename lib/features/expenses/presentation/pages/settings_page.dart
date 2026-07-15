import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/utils/app_constants.dart';

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
        padding: const EdgeInsets.all(20),
        children: [
          // ── Appearance Section ───────────────────────
          _SectionHeader(title: 'Appearance'),
          const SizedBox(height: 12),
          _ThemeToggleTile(),
          const SizedBox(height: 24),

          // ── General Section ──────────────────────────
          _SectionHeader(title: 'General'),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.attach_money,
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
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.download_outlined,
            iconColor: AppColors.primary,
            title: 'Export Data',
            subtitle: 'Export transactions as CSV',
            onTap: () {
              // TODO: export in future session
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Coming soon')));
            },
          ),
          const SizedBox(height: 24),

          // ── About Section ────────────────────────────
          _SectionHeader(title: 'About'),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.info_outline,
            iconColor: AppColors.primaryLight,
            title: 'App Version',
            subtitle: '1.0.0',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.code,
            iconColor: AppColors.primary,
            title: 'Built with',
            subtitle: 'Flutter + Firebase + Clean Architecture',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// Section header label
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: AppTextStyles.label.copyWith(
        color: AppColors.primary,
        letterSpacing: 1.5,
      ),
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Icon changes based on current theme
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Theme', style: AppTextStyles.cardTitle),
                    Text(
                      isDark ? 'Dark Mode' : 'Light Mode',
                      style: AppTextStyles.cardSubTitle,
                    ),
                  ],
                ),
              ),
              // Toggle switch
              Switch(
                value: isDark,
                onChanged: (_) => context.read<ThemeCubit>().toggle(),
                activeColor: AppColors.primary,
              ),
            ],
          ),
        );
      },
    );
  }
}

// Reusable settings tile
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.cardTitle),
                  Text(subtitle, style: AppTextStyles.cardSubTitle),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
