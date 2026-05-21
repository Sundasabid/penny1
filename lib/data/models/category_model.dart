import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/category.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.iconCodePoint,
    required super.colorHex,
    required super.type,
    required super.isDefault,
  });

  factory CategoryModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      iconCodePoint: data['iconCodePoint'] ?? '0xe586',
      colorHex: data['colorHex'] ?? '0xFF9E9E9E',
      type: CategoryType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => CategoryType.expense,
      ),
      isDefault: data['isDefault'] ?? false,
    );
  }

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      iconCodePoint: entity.iconCodePoint,
      colorHex: entity.colorHex,
      type: entity.type,
      isDefault: entity.isDefault,
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'name': name,
      'iconCodePoint': iconCodePoint,
      'colorHex': colorHex,
      'type': type.toString(),
      'isDefault': isDefault,
    };
  }
}
