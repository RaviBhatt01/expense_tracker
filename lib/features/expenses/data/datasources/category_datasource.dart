import '../models/category_model.dart';

abstract class CategoryDatasource {
  Future<List<CategoryModel>> getCategories();
  Future<void> addCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
  Future<bool> categoriesExist();
  Future<void> seedDefaultCategories(List<CategoryModel> categories);
}
