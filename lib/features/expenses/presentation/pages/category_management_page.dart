import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/category.dart';
import '../cubit/category_cubit.dart';

@RoutePage()
class CategoryManagementPage extends StatelessWidget {
  const CategoryManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text('Categories', style: AppTextStyles.sectionTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.maybePop(),
        ),
        actions: [
          // Add button in AppBar — consistent with Budgets page
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () => _showAddCategorySheet(context),
              icon: const Icon(
                Icons.add_circle_outline,
                color: AppColors.primary,
                size: 18,
              ),
              label: const Text(
                'Add',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox(),
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            loaded: (categories) {
              final defaults = categories.where((c) => !c.isCustom).toList();
              final custom = categories.where((c) => c.isCustom).toList();

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                children: [
                  // ── Custom Categories ──────────────────
                  if (custom.isNotEmpty) ...[
                    _SectionHeader(
                      title: 'My Categories',
                      count: custom.length,
                    ),
                    const SizedBox(height: 12),
                    // Grouped card for custom categories
                    _CategoryGroup(
                      categories: custom,
                      canDelete: true,
                      onDelete: (cat) => _confirmDelete(context, cat),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // ── Default Categories ─────────────────
                  _SectionHeader(
                    title: 'Default Categories',
                    count: defaults.length,
                    subtitle: 'Cannot be deleted',
                  ),
                  const SizedBox(height: 12),
                  _CategoryGroup(categories: defaults, canDelete: false),
                ],
              );
            },
            error: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.expense,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(message, style: AppTextStyles.bodySecondary),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Category', style: AppTextStyles.sectionTitle),
        content: Text(
          'Delete "${category.name}"?\n\nExisting transactions keep this category but it won\'t appear in new transactions.',
          style: AppTextStyles.bodySecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CategoryCubit>().deleteCategory(category.id);
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: AppColors.expense,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCategorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<CategoryCubit>(),
        child: const _AddCategorySheet(),
      ),
    );
  }
}

// Section header with count badge
class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final String? subtitle;

  const _SectionHeader({
    required this.title,
    required this.count,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.label.copyWith(
              color: AppColors.primary,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Count badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(width: 8),
          Text(subtitle!, style: AppTextStyles.bodySecondary),
        ],
      ],
    );
  }
}

// Groups categories into one card — matches Settings page pattern
class _CategoryGroup extends StatelessWidget {
  final List<Category> categories;
  final bool canDelete;
  final void Function(Category)? onDelete;

  const _CategoryGroup({
    required this.categories,
    required this.canDelete,
    this.onDelete,
  });

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
      child: Column(
        children: categories.asMap().entries.map((entry) {
          final index = entry.key;
          final cat = entry.value;
          final isLast = index == categories.length - 1;

          return Column(
            children: [
              _CategoryTile(
                category: cat,
                canDelete: canDelete,
                onDelete: onDelete != null ? () => onDelete!(cat) : null,
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 60,
                  endIndent: 16,
                  color: Theme.of(context).dividerColor,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final Category category;
  final bool canDelete;
  final VoidCallback? onDelete;

  const _CategoryTile({
    required this.category,
    required this.canDelete,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = category.color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {}, // placeholder for future edit action
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Category icon with colored background
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(category.icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category.name, style: AppTextStyles.cardTitle),
                    const SizedBox(height: 2),
                    // Type chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (category.type == 'expense'
                                    ? AppColors.expense
                                    : AppColors.income)
                                .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        category.type == 'expense' ? 'Expense' : 'Income',
                        style: TextStyle(
                          color: category.type == 'expense'
                              ? AppColors.expense
                              : AppColors.income,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Action — lock for default, delete for custom
              if (canDelete)
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.expense.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.expense,
                      size: 18,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Bottom sheet to add a new category
class _AddCategorySheet extends StatefulWidget {
  const _AddCategorySheet();

  @override
  State<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<_AddCategorySheet> {
  final _nameController = TextEditingController();
  String _selectedType = 'expense';
  int _selectedIconCode = Icons.category.codePoint;
  int _selectedColorValue = const Color(0xFF7C3AED).value;

  // Available icons for user to pick from
  final List<IconData> _availableIcons = [
    Icons.restaurant,
    Icons.directions_car,
    Icons.shopping_bag,
    Icons.favorite,
    Icons.movie,
    Icons.school,
    Icons.receipt,
    Icons.home,
    Icons.flight,
    Icons.fitness_center,
    Icons.music_note,
    Icons.pets,
    Icons.sports_soccer,
    Icons.coffee,
    Icons.phone,
    Icons.computer,
    Icons.book,
    Icons.brush,
    Icons.camera,
    Icons.games,
  ];

  // Available colors for user to pick from
  final List<Color> _availableColors = [
    const Color(0xFF7C3AED), // bold violet
    const Color(0xFF6366F1), // indigo
    const Color(0xFFEF4444), // bold red
    const Color(0xFFEC4899), // hot pink
    const Color(0xFFF97316), // vivid orange
    const Color(0xFFF59E0B), // amber
    const Color(0xFF10B981), // emerald
    const Color(0xFF84CC16), // lime green
    const Color(0xFF3B82F6), // bright blue
    const Color(0xFF06B6D4), // cyan
    const Color(0xFF14B8A6), // teal
    const Color(0xFFFF6B35), // coral orange
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }

    context.read<CategoryCubit>().addCategory(
      name: _nameController.text.trim(),
      iconCode: _selectedIconCode,
      colorValue: _selectedColorValue,
      type: _selectedType,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final selectedColor = Color(_selectedColorValue);

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.category_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('New Category', style: AppTextStyles.sectionTitle),
                    Text(
                      'Customize icon and color',
                      style: AppTextStyles.bodySecondary,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Live preview card
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: selectedColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selectedColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selectedColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        IconData(
                          _selectedIconCode,
                          fontFamily: 'MaterialIcons',
                        ),
                        color: selectedColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _nameController.text.isEmpty
                          ? 'Preview'
                          : _nameController.text,
                      style: AppTextStyles.cardTitle.copyWith(
                        color: selectedColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Name field
            const Text('Name', style: AppTextStyles.label),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'e.g. Gym, Netflix, Rent',
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Type selector
            const Text('Type', style: AppTextStyles.label),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = 'expense'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedType == 'expense'
                              ? AppColors.expense
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Expense',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedType == 'expense'
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = 'income'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedType == 'income'
                              ? AppColors.income
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Income',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedType == 'income'
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Icon picker
            const Text('Icon', style: AppTextStyles.label),
            const SizedBox(height: 8),
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _availableIcons.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final icon = _availableIcons[index];
                  final isSelected = icon.codePoint == _selectedIconCode;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedIconCode = icon.codePoint),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? selectedColor.withOpacity(0.15)
                            : Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? selectedColor
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected
                            ? selectedColor
                            : AppColors.textSecondary,
                        size: 22,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Color picker
            const Text('Color', style: AppTextStyles.label),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _availableColors.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final color = _availableColors[index];
                  final isSelected = color.value == _selectedColorValue;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedColorValue = color.value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          // White border shows on dark,
                          // transparent shows selected color glow
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 2.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.6),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 18,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Add Category',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
