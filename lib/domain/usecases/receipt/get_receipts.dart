import '../../entities/receipt.dart';
import '../../repositories/receipt_repository.dart';

class GetReceipts {
  final ReceiptRepository repository;
  const GetReceipts(this.repository);

  Future<List<ReceiptEntity>> call() {
    return repository.getReceipts();
  }
}
