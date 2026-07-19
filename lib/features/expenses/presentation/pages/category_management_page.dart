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
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
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
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddCategorySheet(context),
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
                // Separate default and custom categories
                final defaults = categories.where((c) => !c.isCustom).toList();
                final custom = categories.where((c) => c.isCustom).toList();

                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Custom categories section
                    if (custom.isNotEmpty) ...[
                      Text("My Categories", style: AppTextStyles.sectionTitle),
                      const SizedBox(height: 12),
                      ...custom.map(
                        (cat) => _CategoryTile(
                          category: cat,
                          canDelete: true,
                          onDelete: () => _confirmDelete(context, cat),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Default categories section
                    Text(
                      "Default Categories",
                      style: AppTextStyles.sectionTitle,
                    ),
                    const SizedBox(height: 12),
                    ...defaults.map(
                      (cat) => _CategoryTile(category: cat, canDelete: false),
                    ),
                  ],
                );
              },
              error: (message) => Center(
                child: Text(message, style: AppTextStyles.bodySecondary),
              ),
            );
          },
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Delete Category', style: AppTextStyles.sectionTitle),
        content: Text(
          'Delete "${category.name}"? Existing transactions will keep this category but it won\'t appear in new transactions.',
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
              style: TextStyle(color: AppColors.expense),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return BlocProvider.value(
          value: context.read<CategoryCubit>(),
          child: const _AddCategorySheet(),
        );
      },
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

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor, width: 0.5),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(category.icon, color: color, size: 20),
        ),
        title: Text(category.name, style: AppTextStyles.cardTitle),
        subtitle: Text(
          category.type == 'expense' ? 'Expense' : 'Income',
          style: AppTextStyles.bodySecondary,
        ),
        // Lock icon for default, delete for custom
        trailing: canDelete
            ? IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.expense,
                ),
                onPressed: onDelete,
              )
            : const Icon(
                Icons.lock_outline,
                color: AppColors.textSecondary,
                size: 18,
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
  int _selectedColorValue = const Color(0xFF6C63FF).value;

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
    const Color(0xFF6C63FF),
    const Color(0xFFFF6B6B),
    const Color(0xFF4ECDC4),
    const Color(0xFFFFBE0B),
    const Color(0xFF4CAF50),
    const Color(0xFF2196F3),
    const Color(0xFFFF9800),
    const Color(0xFF9C27B0),
    const Color(0xFFE91E63),
    const Color(0xFF00BCD4),
    const Color(0xFF8BC34A),
    const Color(0xFFFF5722),
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

    return SafeArea(
      child: Padding(
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
              const Text('Add Category', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 20),

              // Preview
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
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
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _nameController.text.isEmpty
                          ? 'Category Name'
                          : _nameController.text,
                      style: AppTextStyles.cardTitle,
                    ),
                  ],
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
                ),
              ),
              const SizedBox(height: 16),

              // Type selector
              const Text('Type', style: AppTextStyles.label),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = 'expense'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedType == 'expense'
                              ? AppColors.expense
                              : Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Expense',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedType == 'expense'
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = 'income'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedType == 'income'
                              ? AppColors.income
                              : Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Income',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedType == 'income'
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
                        width: 50,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? selectedColor.withOpacity(0.2)
                              : Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(10),
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
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final color = _availableColors[index];
                    final isSelected = color.value == _selectedColorValue;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedColorValue = color.value),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Colors.white
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text(
                    'Add Category',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              // const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
