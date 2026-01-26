import '../../entities/receipt.dart';

import '../../repositories/receipt_repository.dart';

class SaveReceipt {
  final ReceiptRepository repository;

  SaveReceipt(this.repository);

  /// Bloc calls: await saveReceipt(ReceiptEntity(...));
  Future<void> call(ReceiptEntity receipt) async {
    await repository.saveReceipt(receipt);
  }
}
