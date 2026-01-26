class ReceiptEntity {
  final String id;
  final String merchant;
  final double amount;
  final DateTime date;
  final String imagePath;
  final String rawText;

  const ReceiptEntity({
    required this.id,
    required this.merchant,
    required this.amount,
    required this.date,
    required this.imagePath,
    required this.rawText,
  });
}
