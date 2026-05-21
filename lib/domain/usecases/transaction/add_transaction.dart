import '../../entities/transaction.dart';
import '../../repositories/transaction_repository.dart';
import '../../repositories/budget_repository.dart';

class AddTransactionUseCase {
  final TransactionRepository transactionRepository;
  final BudgetRepository budgetRepository;

  AddTransactionUseCase(this.transactionRepository, this.budgetRepository);

  Future<void> call(TransactionEntity transaction) async {
    await transactionRepository.addTransaction(transaction);
    if (!transaction.isIncome) {
      await budgetRepository.updateSpentAmount(
        transaction.category,
        transaction.amount,
      );
    }
  }
}
