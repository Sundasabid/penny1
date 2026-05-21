import 'package:equatable/equatable.dart';

enum BillingCycle {
  weekly,
  monthly,
  yearly
}

class SubscriptionEntity extends Equatable {
  final String id;
  final String name;
  final double amount;
  final DateTime nextDueDate;
  final BillingCycle cycle;
  final String category;

  const SubscriptionEntity({
    required this.id,
    required this.name,
    required this.amount,
    required this.nextDueDate,
    required this.cycle,
    required this.category,
  });

  SubscriptionEntity copyWith({
    String? id,
    String? name,
    double? amount,
    DateTime? nextDueDate,
    BillingCycle? cycle,
    String? category,
  }) {
    return SubscriptionEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      cycle: cycle ?? this.cycle,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'nextDueDate': nextDueDate.toIso8601String(),
      'cycle': cycle.name,
      'category': category,
    };
  }

  factory SubscriptionEntity.fromMap(Map<String, dynamic> map, String id) {
    BillingCycle parseCycle(String cycleString) {
      switch (cycleString) {
        case 'weekly':
          return BillingCycle.weekly;
        case 'yearly':
          return BillingCycle.yearly;
        case 'monthly':
        default:
          return BillingCycle.monthly;
      }
    }

    return SubscriptionEntity(
      id: id,
      name: map['name'] ?? 'Unknown',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      nextDueDate: map['nextDueDate'] != null 
          ? DateTime.parse(map['nextDueDate']) 
          : DateTime.now(),
      cycle: parseCycle(map['cycle'] ?? 'monthly'),
      category: map['category'] ?? 'Others',
    );
  }

  @override
  List<Object?> get props => [id, name, amount, nextDueDate, cycle, category];
}
