import '../entities/receipt.dart';

abstract class ReceiptRepository {
  Future<void> saveReceipt(ReceiptEntity receipt);
  Future<List<ReceiptEntity>> getReceipts();

  // Scanner / picker
  Future<String> pickReceiptImage();

  // OCR
  Future<String> extractTextFromReceipt(String imageRef);

  Future<void> deleteReceipt(String id);

  // AI-powered Extraction
  Future<Map<String, dynamic>> extractDetailsWithAI(String imagePath, List<String> availableCategories);
}
