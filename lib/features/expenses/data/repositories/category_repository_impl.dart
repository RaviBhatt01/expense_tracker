import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/default_categories.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_datasource.dart';
import '../models/category_model.dart';

@LazySingleton(as: CategoryRepository)
class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryDatasource _datasource;

  CategoryRepositoryImpl({required CategoryDatasource datasource})
    : _datasource = datasource;

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final models = await _datasource.getCategories();
      // Convert models to entities before returning to domain layer
      final categories = models.map((m) => m.toEntity()).toList();
      return Right(categories);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addCategory(Category category) async {
    try {
      final model = CategoryModel.fromEntity(category);
      await _datasource.addCategory(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      await _datasource.deleteCategory(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> seedDefaultCategories() async {
    try {
      // Only seed if no categories exist yet
      final exists = await _datasource.categoriesExist();
      if (!exists) {
        await _datasource.seedDefaultCategories(DefaultCategories.all);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
