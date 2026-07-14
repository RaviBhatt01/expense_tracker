import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/expense.dart';
import '../cubit/category_cubit.dart';

/// Horizontal scrollable list of category chips
/// Filters categories based on selected transaction type
class CategoryPicker extends StatelessWidget {
  final TransactionType selectedType;
  final String? selectedCategoryId;
  final ValueChanged<String> onCategorySelected;

  const CategoryPicker({
    super.key,
    required this.selectedType,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
        return state.when(
          initial: () => const SizedBox(),
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          // Filter categories by current transaction type
          loaded: (categories) {
            final filtered = categories
                .where((c) => c.type == selectedType.name)
                .toList();

            if (filtered.isEmpty) {
              return const Text(
                'No categories found',
                style: AppTextStyles.bodySecondary,
              );
            }

            return SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final category = filtered[index];
                  final isSelected = category.id == selectedCategoryId;

                  return _CategoryChip(
                    category: category,
                    isSelected: isSelected,
                    onTap: () => onCategorySelected(category.id),
                  );
                },
              ),
            );
          },
          error: (message) =>
              Text(message, style: const TextStyle(color: AppColors.expense)),
        );
      },
    );
  }
}

/// Individual category chip with icon, color and label
class _CategoryChip extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Convert stored color int back to Color object
    final color = category.color;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 80,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          // Selected → colored background, not selected → surface
          color: isSelected ? color.withOpacity(0.2) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            // Selected → colored border, not selected → transparent
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Category icon with its stored color
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                // Convert stored iconCode int back to IconData
                category.icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
              style: AppTextStyles.bodySecondary.copyWith(
                fontSize: 10,
                // Bold when selected
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
