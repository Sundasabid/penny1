import 'package:equatable/equatable.dart';

enum TransactionSource { manual, receipt, sms }

/// Core business object used by Bloc & UseCases
class TransactionEntity extends Equatable {
  final String id;
  final String merchant;
  final String category;
  final double amount;
  final DateTime dateTime;
  final String paymentMethod;
  final TransactionSource source;
  final bool isIncome;

  /// Link to a receipt (only for receipt-sourced transactions)
  final String? receiptId;

  const TransactionEntity({
    required this.id,
    required this.merchant,
    required this.category,
    required this.amount,
    required this.dateTime,
    required this.paymentMethod,
    required this.isIncome,
    required this.source,

    // ✅ Make optional so manual flow is not forced to provide it
    this.receiptId,
  });

  /// Optional helper: easy way to set receiptId without changing other fields
  TransactionEntity copyWith({
    String? id,
    String? merchant,
    String? category,
    double? amount,
    DateTime? dateTime,
    String? paymentMethod,
    TransactionSource? source,
    bool? isIncome,
    String? receiptId,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      merchant: merchant ?? this.merchant,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      dateTime: dateTime ?? this.dateTime,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isIncome: isIncome ?? this.isIncome,
      source: source ?? this.source,
      receiptId: receiptId ?? this.receiptId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    merchant,
    category,
    amount,
    dateTime,
    paymentMethod,
    isIncome,
    source,
    receiptId,
  ];
}
