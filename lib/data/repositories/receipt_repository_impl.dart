
import '../../domain/entities/receipt.dart';
import '../../domain/repositories/receipt_repository.dart';

class InMemoryReceiptRepository implements ReceiptRepository {
  final List<ReceiptEntity> _receipts = [];

  @override
  Future<void> saveReceipt(ReceiptEntity receipt) async {
    _receipts.insert(0, receipt);
  }

  @override
  Future<List<ReceiptEntity>> getReceipts() async {
    return List.unmodifiable(_receipts);
  }

  // ---------------------------------------------------------------------------
  // Required by receipt scanner flow (stubs for testing)
  // ---------------------------------------------------------------------------

  @override
  Future<String> pickReceiptImage() async {
    // Stub: return a fake path or implement with image_picker in data layer.
    // In real implementation, return local file path captured from camera/gallery.
    return 'in_memory_receipt_image.jpg';
  }

  @override
  Future<String> extractTextFromReceipt(String imageRef) async {
    // Stub: replace with ML Kit OCR in real repo implementation.
    return '''
AL FATAH
Date: 26/01/2026
Milk Bread Eggs
TOTAL: Rs 1,245
''';
  }
}
