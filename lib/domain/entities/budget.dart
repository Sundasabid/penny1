import 'package:equatable/equatable.dart';

class BudgetEntity extends Equatable {
  final String id;
  final String category;
  final double limit;
  final double spent;
  final String period; // 'Monthly' or 'Weekly'

  const BudgetEntity({
    required this.id,
    required this.category,
    required this.limit,
    required this.spent,
    this.period = 'Monthly',
  });

  double get remaining => limit - spent;
  double get progress => spent / limit;
  bool get isExceeded => spent > limit;
  bool get isApproaching => spent > (limit * 0.8) && spent <= limit;

  BudgetEntity copyWith({
    String? id,
    String? category,
    double? limit,
    double? spent,
    String? period,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      category: category ?? this.category,
      limit: limit ?? this.limit,
      spent: spent ?? this.spent,
      period: period ?? this.period,
    );
  }

  @override
  List<Object?> get props => [id, category, limit, spent, period];
}
