import 'package:equatable/equatable.dart';

/// Where the transaction came from.
enum TransactionSource { manual, receipt, sms }

/// Core business object used by Bloc & UseCases
class TransactionEntity extends Equatable {
  final String id;

  /// Merchant / payee name (manual: user-entered, receipt: parsed)
  final String merchant;

  /// Your app's spend category label (e.g., Grocery, Transport, Dining, etc.)
  final String category;

  /// Amount of the transaction
  final double amount;

  /// Transaction timestamp
  final DateTime dateTime;

  /// e.g., Cash, Card, Bank, Wallet, etc.
  final String paymentMethod;

  /// Where it came from (manual / receipt / sms)
  final TransactionSource source;

  /// true = income, false = expense
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
    this.receiptId,
  });

  // ---------------------------------------------------------------------------
  // FACTORY HELPERS (Manual + Receipt)
  // ---------------------------------------------------------------------------

  /// Manual entry (Expense)
  factory TransactionEntity.manualExpense({
    required String id,
    required String merchant,
    required String category,
    required double amount,
    required DateTime dateTime,
    required String paymentMethod,
  }) {
    return TransactionEntity(
      id: id,
      merchant: merchant,
      category: category,
      amount: amount,
      dateTime: dateTime,
      paymentMethod: paymentMethod,
      isIncome: false,
      source: TransactionSource.manual,
      receiptId: null,
    );
  }

  /// Manual entry (Income)
  factory TransactionEntity.manualIncome({
    required String id,
    required String merchant,
    required String category,
    required double amount,
    required DateTime dateTime,
    required String paymentMethod,
  }) {
    return TransactionEntity(
      id: id,
      merchant: merchant,
      category: category,
      amount: amount,
      dateTime: dateTime,
      paymentMethod: paymentMethod,
      isIncome: true,
      source: TransactionSource.manual,
      receiptId: null,
    );
  }

  /// Receipt scan (Expense)
  factory TransactionEntity.receiptExpense({
    required String id,
    required String merchant,
    required String category,
    required double amount,
    required DateTime dateTime,
    required String paymentMethod,
    required String receiptId,
  }) {
    return TransactionEntity(
      id: id,
      merchant: merchant,
      category: category,
      amount: amount,
      dateTime: dateTime,
      paymentMethod: paymentMethod,
      isIncome: false,
      source: TransactionSource.receipt,
      receiptId: receiptId,
    );
  }

  /// Receipt scan (Income) - uncommon, but supported if you ever need it.
  factory TransactionEntity.receiptIncome({
    required String id,
    required String merchant,
    required String category,
    required double amount,
    required DateTime dateTime,
    required String paymentMethod,
    required String receiptId,
  }) {
    return TransactionEntity(
      id: id,
      merchant: merchant,
      category: category,
      amount: amount,
      dateTime: dateTime,
      paymentMethod: paymentMethod,
      isIncome: true,
      source: TransactionSource.receipt,
      receiptId: receiptId,
    );
  }

  /// SMS imported (Expense)
  factory TransactionEntity.smsExpense({
    required String id,
    required String merchant,
    required String category,
    required double amount,
    required DateTime dateTime,
    required String paymentMethod,
  }) {
    return TransactionEntity(
      id: id,
      merchant: merchant,
      category: category,
      amount: amount,
      dateTime: dateTime,
      paymentMethod: paymentMethod,
      isIncome: false,
      source: TransactionSource.sms,
      receiptId: null,
    );
  }

  /// SMS imported (Income)
  factory TransactionEntity.smsIncome({
    required String id,
    required String merchant,
    required String category,
    required double amount,
    required DateTime dateTime,
    required String paymentMethod,
  }) {
    return TransactionEntity(
      id: id,
      merchant: merchant,
      category: category,
      amount: amount,
      dateTime: dateTime,
      paymentMethod: paymentMethod,
      isIncome: true,
      source: TransactionSource.sms,
      receiptId: null,
    );
  }

  // ---------------------------------------------------------------------------
  // COPY WITH
  // ---------------------------------------------------------------------------

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
