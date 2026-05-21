import 'package:equatable/equatable.dart';

class PlannedPurchase extends Equatable {
  final String id;
  final String name;
  final double amount;
  final DateTime targetDate;
  final DateTime createdAt;
  final String? aiAdvice;
  final bool isAiLoading;

  const PlannedPurchase({
    required this.id,
    required this.name,
    required this.amount,
    required this.targetDate,
    required this.createdAt,
    this.aiAdvice,
    this.isAiLoading = false,
  });

  PlannedPurchase copyWith({
    String? aiAdvice,
    bool? isAiLoading,
  }) {
    return PlannedPurchase(
      id: id,
      name: name,
      amount: amount,
      targetDate: targetDate,
      createdAt: createdAt,
      aiAdvice: aiAdvice ?? this.aiAdvice,
      isAiLoading: isAiLoading ?? this.isAiLoading,
    );
  }

  @override
  List<Object?> get props => [id, name, amount, targetDate, createdAt, aiAdvice, isAiLoading];
}
