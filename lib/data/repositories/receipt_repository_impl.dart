import '../../domain/entities/receipt.dart';
import '../../domain/repositories/receipt_repository.dart';

class InMemoryReceiptRepository implements ReceiptRepository {
  final List<ReceiptEntity> _receipts = [];

  @override
  Future<void> addReceipt(ReceiptEntity receipt) async {
    _receipts.insert(0, receipt);
  }

  @override
  Future<List<ReceiptEntity>> getReceipts() async {
    return List.unmodifiable(_receipts);
  }
}
