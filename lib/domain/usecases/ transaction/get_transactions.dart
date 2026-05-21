import '../../entities/transaction.dart';
import '../../repositories/transaction_repository.dart';

/// Use case responsible for fetching all transactions
/// Used by History screen
class GetTransactionsUseCase {
  final TransactionRepository repository;

  GetTransactionsUseCase(this.repository);

  /// Returns all stored transactions
  Future<List<TransactionEntity>> call() async {
    return repository.getTransactions();
  }
}
