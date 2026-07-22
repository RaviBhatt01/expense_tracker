import 'package:flutter/material.dart';

/// All colors used throughout the app.
/// Never use raw Color() values outside this file.
class AppColors {
  AppColors._();

  // ─── Background Colors ───────────────────────────────────────
  /// Main app background
  static const Color background = Color(0xFF111114);

  /// Card and container background
  static const Color surface = Color(0xFF1C1C21);

  /// Input field background
  static const Color inputBackground = Color(0xFF252530);

  // ─── Brand Colors ─────────────────────────────────────────────
  /// Primary — buttons, FAB, active states
  static const Color primary = Color(0xFF7C3AED);

  /// Lighter primary for hover/pressed states
  static const Color primaryLight = Color(0xFF9F67FF);

  // ─── Semantic Colors ──────────────────────────────────────────
  /// Income amounts and positive values
  static const Color income = Color(0xFF10B981);

  /// Expense amounts and negative values
  static const Color expense = Color(0xFFEF4444);

  /// Warnings — budget approaching limit
  static const Color warning = Color(0xFFF59E0B);

  // ─── Text Colors ──────────────────────────────────────────────
  /// Primary text
  static const Color textPrimary = Colors.white;

  /// Secondary text — labels, dates, captions
  /// NOTE: Do not use directly — use Theme.of(context) for adaptive text
  static const Color textSecondary = Color(0xFF9CA3AF);

  /// Hint text — placeholder text in inputs
  static const Color textHint = Color(0xFF6B7280);

  // ─── Utility ──────────────────────────────────────────────────
  /// Dividers and borders
  static const Color divider = Color(0xFF2D2D3A);

  /// Icon colors on colored backgrounds
  static const Color iconOnColor = Colors.white;
}
