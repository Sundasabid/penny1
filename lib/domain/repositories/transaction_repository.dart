import '../entities/transaction.dart';

/// Contract for transaction data operations.
///
/// Domain layer depends ONLY on this interface.
/// Data layer provides the implementation.
abstract class TransactionRepository {
  /// Add a new transaction
  /// - manual (now)
  /// - receipt / sms (later)
  Future<void> addTransaction(TransactionEntity transaction);

  /// Fetch all transactions
  /// Used by History & Analytics
  Future<List<TransactionEntity>> getTransactions();
}
