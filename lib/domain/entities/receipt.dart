class ReceiptEntity {
  final String id;
  final String imagePath;
  final String merchantName;
  final num amount;
  final String category;
  final DateTime dateTime;

  const ReceiptEntity({
    required this.id,
    required this.imagePath,
    required this.merchantName,
    required this.amount,
    required this.category,
    required this.dateTime,
  });
}
