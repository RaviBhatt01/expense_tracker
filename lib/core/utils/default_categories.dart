import 'package:flutter/material.dart';
import '../../features/expenses/data/models/category_model.dart';

// All default categories seeded on first app launch
// iconCode: use Icons.xxx.codePoint to get the integer
// colorValue: use Color(0xFF...).value to get the integer
class DefaultCategories {
  DefaultCategories._();

  static List<CategoryModel> get all => [
    // ── Expense Categories ──────────────────────────
    CategoryModel(
      id: 'food',
      name: 'Food & Dining',
      iconCode: Icons.restaurant.codePoint,
      colorValue: const Color(0xFFFF6B6B).value,
      type: 'expense',
      isCustom: false,
    ),
    CategoryModel(
      id: 'transport',
      name: 'Transport',
      iconCode: Icons.directions_car.codePoint,
      colorValue: const Color(0xFF4ECDC4).value,
      type: 'expense',
      isCustom: false,
    ),
    CategoryModel(
      id: 'shopping',
      name: 'Shopping',
      iconCode: Icons.shopping_bag.codePoint,
      colorValue: const Color(0xFFFFBE0B).value,
      type: 'expense',
      isCustom: false,
    ),
    CategoryModel(
      id: 'health',
      name: 'Health',
      iconCode: Icons.favorite.codePoint,
      colorValue: const Color(0xFFFF006E).value,
      type: 'expense',
      isCustom: false,
    ),
    CategoryModel(
      id: 'entertainment',
      name: 'Entertainment',
      iconCode: Icons.movie.codePoint,
      colorValue: const Color(0xFF8338EC).value,
      type: 'expense',
      isCustom: false,
    ),
    CategoryModel(
      id: 'education',
      name: 'Education',
      iconCode: Icons.school.codePoint,
      colorValue: const Color(0xFF3A86FF).value,
      type: 'expense',
      isCustom: false,
    ),
    CategoryModel(
      id: 'bills',
      name: 'Bills & Utilities',
      iconCode: Icons.receipt.codePoint,
      colorValue: const Color(0xFFFB5607).value,
      type: 'expense',
      isCustom: false,
    ),
    CategoryModel(
      id: 'general',
      name: 'General',
      iconCode: Icons.category.codePoint,
      colorValue: const Color(0xFF6C63FF).value,
      type: 'expense',
      isCustom: false,
    ),

    // ── Income Categories ───────────────────────────
    CategoryModel(
      id: 'salary',
      name: 'Salary',
      iconCode: Icons.work.codePoint,
      colorValue: const Color(0xFF4CAF50).value,
      type: 'income',
      isCustom: false,
    ),
    CategoryModel(
      id: 'freelance',
      name: 'Freelance',
      iconCode: Icons.laptop.codePoint,
      colorValue: const Color(0xFF00B4D8).value,
      type: 'income',
      isCustom: false,
    ),
    CategoryModel(
      id: 'investment',
      name: 'Investment',
      iconCode: Icons.trending_up.codePoint,
      colorValue: const Color(0xFF06D6A0).value,
      type: 'income',
      isCustom: false,
    ),
    CategoryModel(
      id: 'other_income',
      name: 'Other Income',
      iconCode: Icons.attach_money.codePoint,
      colorValue: const Color(0xFFFFD166).value,
      type: 'income',
      isCustom: false,
    ),
  ];
}
