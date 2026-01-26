import '../entities/receipt.dart';

abstract class ReceiptRepository {
  Future<void> addReceipt(ReceiptEntity receipt);
  Future<List<ReceiptEntity>> getReceipts();
}
