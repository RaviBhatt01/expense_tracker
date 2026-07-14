import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:collection/collection.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/seed_categories.dart';

part 'category_state.dart';
part 'category_cubit.freezed.dart';

@injectable
class CategoryCubit extends Cubit<CategoryState> {
  final GetCategoriesUseCase _getCategories;
  final SeedCategoriesUseCase _seedCategories;

  CategoryCubit({
    required GetCategoriesUseCase getCategories,
    required SeedCategoriesUseCase seedCategories,
  }) : _getCategories = getCategories,
       _seedCategories = seedCategories,
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
}
