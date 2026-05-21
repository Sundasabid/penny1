import '../../entities/transaction.dart';
import '../../repositories/transaction_repository.dart';

/// Use case responsible for adding a new transaction
/// (manual now, receipt/SMS later)
class AddTransactionUseCase {
  final TransactionRepository repository;

  AddTransactionUseCase(this.repository);

  /// Executes the add transaction flow
  Future<void> call(TransactionEntity transaction) async {
    return repository.addTransaction(transaction);
  }
}
