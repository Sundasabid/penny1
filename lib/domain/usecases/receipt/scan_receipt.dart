import '../../repositories/receipt_repository.dart';

class ScanReceipt {
  final ReceiptRepository repository;

  const ScanReceipt(this.repository);

  /// Opens camera / gallery and returns a reference
  /// (file path or URL) to the captured receipt image.
  Future<String> call() {
    return repository.pickReceiptImage();
  }
}
