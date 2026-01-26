import '../../repositories/receipt_repository.dart';

class ProcessOcr {
  final ReceiptRepository repository;

  const ProcessOcr(this.repository);

  Future<String> call(String imageRef) {
    return repository.extractTextFromReceipt(imageRef);
  }
}
