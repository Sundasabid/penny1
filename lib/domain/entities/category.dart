import 'package:equatable/equatable.dart';

enum CategoryType { expense, income }

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String
  iconCodePoint; // Storing as string to be flexible (or int if preferred)
  final String colorHex;
  final CategoryType type;
  final bool isDefault;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorHex,
    required this.type,
    this.isDefault = false,
  });

  // Default Categories Data
  static List<CategoryEntity> get defaultCategories {
    return [
      const CategoryEntity(
        id: 'cat_groceries',
        name: 'Groceries',
        iconCodePoint: '0xe586', // Icons.shopping_cart_rounded
        colorHex: '0xFF4CAF50', // Green
        type: CategoryType.expense,
        isDefault: true,
      ),
      const CategoryEntity(
        id: 'cat_dining',
        name: 'Dining',
        iconCodePoint: '0xe532', // Icons.restaurant_rounded
        colorHex: '0xFFFF9800', // Orange
        type: CategoryType.expense,
        isDefault: true,
      ),
      const CategoryEntity(
        id: 'cat_transport',
        name: 'Transport',
        iconCodePoint: '0xe1d5', // Icons.directions_car_rounded
        colorHex: '0xFF2196F3', // Blue
        type: CategoryType.expense,
        isDefault: true,
      ),
      const CategoryEntity(
        id: 'cat_shopping',
        name: 'Shopping',
        iconCodePoint: '0xe59c', // Icons.shopping_bag_rounded
        colorHex: '0xFF9C27B0', // Purple
        type: CategoryType.expense,
        isDefault: true,
      ),
      const CategoryEntity(
        id: 'cat_utilities',
        name: 'Utilities',
        iconCodePoint: '0xe35d', // Icons.lightbulb_rounded
        colorHex: '0xFFFFC107', // Amber
        type: CategoryType.expense,
        isDefault: true,
      ),
      const CategoryEntity(
        id: 'cat_others',
        name: 'Others',
        iconCodePoint: '0xe3c9', // Icons.more_horiz_rounded
        colorHex: '0xFF9E9E9E', // Grey
        type: CategoryType.expense,
        isDefault: true,
      ),
      // Default Income Categories
      const CategoryEntity(
        id: 'cat_salary',
        name: 'Salary',
        iconCodePoint: '0xe227', // Icons.attach_money_rounded
        colorHex: '0xFF4CAF50', // Green
        type: CategoryType.income,
        isDefault: true,
      ),
      const CategoryEntity(
        id: 'cat_freelance',
        name: 'Freelance',
        iconCodePoint: '0xf0155', // Icons.work_outline_rounded
        colorHex: '0xFF009688', // Teal
        type: CategoryType.income,
        isDefault: true,
      ),
      const CategoryEntity(
        id: 'cat_investment',
        name: 'Investment',
        iconCodePoint: '0xe85d', // Icons.show_chart_rounded
        colorHex: '0xFF2196F3', // Blue
        type: CategoryType.income,
        isDefault: true,
      ),
      const CategoryEntity(
        id: 'cat_gift',
        name: 'Gift',
        iconCodePoint: '0xe8f6', // Icons.card_giftcard_rounded
        colorHex: '0xFFE91E63', // Pink
        type: CategoryType.income,
        isDefault: true,
      ),
      const CategoryEntity(
        id: 'cat_income_others',
        name: 'Others (Income)',
        iconCodePoint: '0xe3c9', // Icons.more_horiz_rounded
        colorHex: '0xFF9E9E9E', // Grey
        type: CategoryType.income,
        isDefault: true,
      ),
    ];
  }

  @override
  List<Object?> get props => [
    id,
    name,
    iconCodePoint,
    colorHex,
    type,
    isDefault,
  ];
}
