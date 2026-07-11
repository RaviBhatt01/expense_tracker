import 'package:flutter/material.dart';
import 'app_colors.dart';

/// All text styles used throughout the app.
/// Never define TextStyle inline outside this file.
class AppTextStyles {
  // Private constructor — never instantiate this class
  AppTextStyles._();

  // ─── Display ──────────────────────────────────────────────────
  /// Large balance amount on home screen
  static const TextStyle balanceAmount = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 36,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  // ─── Headings ─────────────────────────────────────────────────
  /// Section titles like "Recent Transactions"
  static const TextStyle sectionTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  /// Card titles and transaction names
  static const TextStyle cardTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  // ─── Body ─────────────────────────────────────────────────────
  /// Regular body text
  static const TextStyle body = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  /// Secondary body text — dates, captions
  static const TextStyle bodySecondary = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  // ─── Labels ───────────────────────────────────────────────────
  /// Small labels above input fields
  static const TextStyle label = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  /// Greeting text on home screen
  static const TextStyle greeting = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  // ─── Amounts ──────────────────────────────────────────────────
  /// Expense amount — red
  static TextStyle expenseAmount = const TextStyle(
    color: AppColors.expense,
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );

  /// Income amount — green
  static TextStyle incomeAmount = const TextStyle(
    color: AppColors.income,
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );

  /// Summary card amount
  static const TextStyle summaryAmount = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
}
