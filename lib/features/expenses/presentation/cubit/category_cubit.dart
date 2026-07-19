import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:collection/collection.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/add_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/seed_categories.dart';

part 'category_state.dart';
part 'category_cubit.freezed.dart';

@injectable
class CategoryCubit extends Cubit<CategoryState> {
  final GetCategoriesUseCase _getCategories;
  final SeedCategoriesUseCase _seedCategories;
  final AddCategoryUseCase _addCategory;
  final DeleteCategoryUseCase _deleteCategory;

  CategoryCubit({
    required GetCategoriesUseCase getCategories,
    required SeedCategoriesUseCase seedCategories,
    required AddCategoryUseCase addCategory,
    required DeleteCategoryUseCase deleteCategory,
  }) : _getCategories = getCategories,
       _seedCategories = seedCategories,
       _addCategory = addCategory,
       _deleteCategory = deleteCategory,
       super(const CategoryState.initial());

  /// Seeds defaults if needed, then loads all categories
  /// Called once when app starts
  Future<void> initializeCategories() async {
    emit(const CategoryState.loading());

    // First ensure default categories exist in Firestore
    await _seedCategories(NoParams());

    // Then fetch all categories
    final result = await _getCategories(NoParams());

    result.fold(
      (failure) => emit(CategoryState.error(message: failure.message)),
      (categories) => emit(CategoryState.loaded(categories: categories)),
    );
  }

  /// Returns categories filtered by type
  /// Used in Add/Edit transaction form
  List<Category> getCategoriesByType(String type) {
    final state = this.state;
    if (state is! CategoryLoaded) return [];

    return state.categories.where((c) => c.type == type).toList();
  }

  /// Find a single category by its id
  /// Returns null if not found or state is not loaded
  Category? getCategoryById(String id) {
    final state = this.state;
    if (state is! CategoryLoaded) return null;

    return state.categories.firstWhereOrNull((c) => c.id == id);
  }

  /// Add a new custom category
  Future<void> addCategory({
    required String name,
    required int iconCode,
    required int colorValue,
    required String type,
  }) async {
    // Generate id locally — same pattern as expenses
    final id = FirebaseFirestore.instance.collection('categories').doc().id;

    final category = Category(
      id: id,
      name: name,
      iconCode: iconCode,
      colorValue: colorValue,
      type: type,
      isCustom: true, // always true for user-created categories
    );

    final result = await _addCategory(category);

    result.fold(
      (failure) => emit(CategoryState.error(message: failure.message)),
      (_) => initializeCategories(), // reload after adding
    );
  }

  /// Delete a custom category
  /// Default categories cannot be deleted
  Future<void> deleteCategory(String id) async {
    final currentState = state;
    if (currentState is! CategoryLoaded) return;

    // Safety check — never delete default categories
    final category = currentState.categories.firstWhereOrNull(
      (c) => c.id == id,
    );

    if (category == null || !category.isCustom) return;

    final result = await _deleteCategory(id);

    result.fold(
      (failure) => emit(CategoryState.error(message: failure.message)),
      (_) => initializeCategories(),
    );
  }
}
