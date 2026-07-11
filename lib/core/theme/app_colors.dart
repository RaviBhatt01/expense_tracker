import 'package:flutter/material.dart';

/// All colors used throughout the app.
/// Never use raw Color() values outside this file.
class AppColors {
  // Private constructor — this class should never be instantiated
  // All values are static, access them as AppColors.background
  AppColors._();

  // ─── Background Colors ───────────────────────────────────────
  /// Main app background — deep dark blue
  static const Color background = Color(0xFF1E1E2E);

  /// Card and container background — slightly lighter than background
  static const Color surface = Color(0xFF2A2A3E);

  /// Input field background
  static const Color inputBackground = Color(0xFF313145);

  // ─── Brand Colors ─────────────────────────────────────────────
  /// Primary purple — buttons, FAB, active states
  static const Color primary = Color(0xFF6C63FF);

  /// Lighter purple for hover/pressed states
  static const Color primaryLight = Color(0xFF8B85FF);

  // ─── Semantic Colors ──────────────────────────────────────────
  /// Income amounts and positive values
  static const Color income = Color(0xFF4CAF50);

  /// Expense amounts and negative values
  static const Color expense = Color(0xFFE53935);

  /// Warnings — budget approaching limit
  static const Color warning = Color(0xFFFFA726);

  // ─── Text Colors ──────────────────────────────────────────────
  /// Primary text — headings and important content
  static const Color textPrimary = Colors.white;

  /// Secondary text — labels, dates, captions
  static const Color textSecondary = Color(0x99FFFFFF); // white 60%

  /// Hint text — placeholder text in inputs
  static const Color textHint = Color(0x61FFFFFF); // white 38%

  // ─── Utility ──────────────────────────────────────────────────
  /// Dividers and borders
  static const Color divider = Color(0xFF3D3D5C);

  /// Icon colors on colored backgrounds
  static const Color iconOnColor = Colors.white;
}
