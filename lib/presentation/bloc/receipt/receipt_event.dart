abstract class ReceiptEvent {}

class GetReceiptsRequested extends ReceiptEvent {}

class SaveReceiptRequested extends ReceiptEvent {
  final String receiptId;
  final String imagePath;
  final String merchantName;
  final num amount;
  final String category;
  final DateTime dateTime;

  SaveReceiptRequested({
    required this.receiptId,
    required this.imagePath,
    required this.merchantName,
    required this.amount,
    required this.category,
    required this.dateTime,
  });
}

class DeleteReceiptRequested extends ReceiptEvent {
  final dynamic receipt; // Using dynamic to avoid ReceiptEntity import if not needed here, but usually it is. Actually, ReceiptEntity is better.
  DeleteReceiptRequested(this.receipt);
}
