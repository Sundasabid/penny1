import '../../entities/transaction.dart';
import '../../repositories/transaction_repository.dart';
import '../../repositories/budget_repository.dart';

class DeleteTransactionUseCase {
  final TransactionRepository transactionRepository;
  final BudgetRepository budgetRepository;

  DeleteTransactionUseCase(this.transactionRepository, this.budgetRepository);

  Future<void> call(TransactionEntity transaction) async {
    await transactionRepository.deleteTransaction(transaction.id);
    if (!transaction.isIncome) {
      // Revert the spent amount in the budget
      await budgetRepository.updateSpentAmount(
        transaction.category,
        -transaction.amount,
      );
    }
  }
}
