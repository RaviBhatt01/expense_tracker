import 'package:flutter/material.dart';
import 'app_colors.dart';

/// All text styles used throughout the app.
/// Never define TextStyle inline outside this file.
class AppTextStyles {
  AppTextStyles._();

  // No color specified — Flutter uses theme text color automatically
  static const TextStyle balanceAmount = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle cardSubTitle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    // Keep secondary color — will not be perfectly theme-aware
    // but close enough for now
    color: Color(0x99FFFFFF),
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static const TextStyle greeting = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  // Keep semantic colors — these never change with theme
  static TextStyle expenseAmount = const TextStyle(
    color: AppColors.expense,
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );

  static TextStyle incomeAmount = const TextStyle(
    color: AppColors.income,
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle summaryAmount = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
}
