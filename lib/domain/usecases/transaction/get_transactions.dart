import '../../entities/transaction.dart';
import '../../repositories/transaction_repository.dart';

class GetTransactionsUseCase {
  final TransactionRepository repository;

  GetTransactionsUseCase(this.repository);

  Future<List<TransactionEntity>> call() async {
    return repository.getTransactions();
  }
}
