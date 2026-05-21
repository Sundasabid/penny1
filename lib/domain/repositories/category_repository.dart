import '../entities/category.dart';

abstract class CategoryRepository {
  Stream<List<CategoryEntity>> getCategories();
  Future<void> addCategory(CategoryEntity category);
  Future<void> updateCategory(CategoryEntity category);
  Future<void> deleteCategory(String id);
  Future<void> resetToDefaults();
}
