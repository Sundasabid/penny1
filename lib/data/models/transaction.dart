import '../../../domain/entities/transaction.dart';

/// Data-layer representation of a transaction
/// Used for local / remote storage (Hive, Firestore, etc.)
class TransactionModel {
  final String id;
  final String merchant;
  final String category;
  final double amount;
  final DateTime dateTime;
  final String paymentMethod;
  final bool isIncome;

  const TransactionModel({
    required this.id,
    required this.merchant,
    required this.category,
    required this.amount,
    required this.dateTime,
    required this.paymentMethod,
    required this.isIncome,
  });

  /// Convert DOMAIN → DATA
  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      merchant: entity.merchant,
      category: entity.category,
      amount: entity.amount,
      dateTime: entity.dateTime,
      paymentMethod: entity.paymentMethod,
      isIncome: entity.isIncome,
    );
  }

  /// Convert DATA → DOMAIN
  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      merchant: merchant,
      category: category,
      amount: amount,
      dateTime: dateTime,
      paymentMethod: paymentMethod,
      isIncome: isIncome,
    );
  }

  /// For Firestore / JSON storage (future)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'merchant': merchant,
      'category': category,
      'amount': amount,
      'dateTime': dateTime.toIso8601String(),
      'paymentMethod': paymentMethod,
      'isIncome': isIncome,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      merchant: map['merchant'] as String,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      dateTime: DateTime.parse(map['dateTime'] as String),
      paymentMethod: map['paymentMethod'] as String,
      isIncome: map['isIncome'] as bool,
    );
  }
}
