import '../../entities/receipt.dart';
import '../../repositories/receipt_repository.dart';
import '../../repositories/transaction_repository.dart';
import '../../repositories/budget_repository.dart';

class DeleteReceiptUseCase {
  final ReceiptRepository receiptRepository;
  final TransactionRepository transactionRepository;
  final BudgetRepository budgetRepository;

  DeleteReceiptUseCase({
    required this.receiptRepository,
    required this.transactionRepository,
    required this.budgetRepository,
  });

  Future<void> call(ReceiptEntity receipt) async {
    // 1. Delete from Receipt repository
    await receiptRepository.deleteReceipt(receipt.id);

    // 2. Find and delete linked transaction
    // The transaction ID was generated as 'tx_${receipt.id}' in ReceiptProcessHelper
    final txId = 'tx_${receipt.id}';
    await transactionRepository.deleteTransaction(txId);

    // 3. Update Budget (Deduct amount)
    // We pass a negative amount to subtract it from the 'spent' total
    await budgetRepository.updateSpentAmount(
      receipt.category,
      -receipt.amount.toDouble(),
    );
  }
}
