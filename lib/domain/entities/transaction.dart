import 'package:equatable/equatable.dart';

/// Core business object used by Bloc & UseCases
class TransactionEntity extends Equatable {
  final String id;
  final String merchant;
  final String category;
  final double amount;
  final DateTime dateTime;
  final String paymentMethod;
  final bool isIncome;

  const TransactionEntity({
    required this.id,
    required this.merchant,
    required this.category,
    required this.amount,
    required this.dateTime,
    required this.paymentMethod,
    required this.isIncome,
  });

  @override
  List<Object?> get props => [
    id,
    merchant,
    category,
    amount,
    dateTime,
    paymentMethod,
    isIncome,
  ];
}
