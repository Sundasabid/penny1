import 'package:equatable/equatable.dart';
import '../../../domain/entities/category.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategoriesRequested extends CategoryEvent {}

class AddCategoryRequested extends CategoryEvent {
  final CategoryEntity category;
  const AddCategoryRequested(this.category);
  @override
  List<Object?> get props => [category];
}

class UpdateCategoryRequested extends CategoryEvent {
  final CategoryEntity category;
  const UpdateCategoryRequested(this.category);
  @override
  List<Object?> get props => [category];
}

class DeleteCategoryRequested extends CategoryEvent {
  final String id;
  const DeleteCategoryRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class ResetCategoriesRequested extends CategoryEvent {}

class CategoriesUpdated extends CategoryEvent {
  final List<CategoryEntity> categories;
  const CategoriesUpdated(this.categories);
  @override
  List<Object?> get props => [categories];
}

class CategoriesError extends CategoryEvent {
  final String message;
  const CategoriesError(this.message);
  @override
  List<Object?> get props => [message];
}
