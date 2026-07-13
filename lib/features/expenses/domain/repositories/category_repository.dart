import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/category.dart';

abstract class CategoryRepository {
  /// Fetch all categories from Firestore
  Future<Either<Failure, List<Category>>> getCategories();

  /// Add a new custom category
  Future<Either<Failure, void>> addCategory(Category category);

  /// Delete a custom category
  /// Default categories cannot be deleted
  Future<Either<Failure, void>> deleteCategory(String id);

  /// Seed default categories on first launch
  /// Only runs if no categories exist yet
  Future<Either<Failure, void>> seedDefaultCategories();
}
