import 'package:flutter/material.dart';
import 'app_colors.dart';

/// All text styles used throughout the app.
/// Never define TextStyle inline outside this file.
class AppTextStyles {
  AppTextStyles._();

  // ─── Display ──────────────────────────────────────────────────
  /// Large balance amount on home screen
  static const TextStyle balanceAmount = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    // No color — uses theme text color automatically
  );

  // ─── Headings ─────────────────────────────────────────────────
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle cardSubTitle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    // No hardcoded color — inherits from theme
  );

  // ─── Body ─────────────────────────────────────────────────────
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  /// Secondary body — uses neutral grey that works on both themes
  static const TextStyle bodySecondary = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary, // neutral grey — readable on both themes
  );

  // ─── Labels ───────────────────────────────────────────────────
  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    color: AppColors.textSecondary,
  );

  static const TextStyle greeting = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  // ─── Amounts ──────────────────────────────────────────────────
  /// Semantic colors — never change with theme
  static const TextStyle expenseAmount = TextStyle(
    color: AppColors.expense,
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle incomeAmount = TextStyle(
    color: AppColors.income,
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle summaryAmount = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
}
