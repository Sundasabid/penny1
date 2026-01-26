// lib/data/models/receipt/ocr_result_model.dart

class OcrResultModel {
  final String extractedText;

  // Parsed fields (from ReceiptParser)
  final String merchantName;
  final double totalAmount;
  final String category;
  final DateTime? date;
  final String currency;

  const OcrResultModel({
    required this.extractedText,
    required this.merchantName,
    required this.totalAmount,
    required this.category,
    required this.currency,
    this.date,
  });

  // If you already had fromJson/toJson, keep keys compatible.
  // Add new keys as optional.
  factory OcrResultModel.fromJson(Map<String, dynamic> json) {
    return OcrResultModel(
      extractedText: (json['extractedText'] ?? '') as String,
      merchantName: (json['merchantName'] ?? 'Unknown Merchant') as String,
      totalAmount: (json['totalAmount'] is num) ? (json['totalAmount'] as num).toDouble() : 0.0,
      category: (json['category'] ?? 'other') as String,
      currency: (json['currency'] ?? 'PKR') as String,
      date: json['date'] != null ? DateTime.tryParse(json['date'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'extractedText': extractedText,
      'merchantName': merchantName,
      'totalAmount': totalAmount,
      'category': category,
      'currency': currency,
      'date': date?.toIso8601String(),
    };
  }

  OcrResultModel copyWith({
    String? extractedText,
    String? merchantName,
    double? totalAmount,
    String? category,
    DateTime? date,
    String? currency,
  }) {
    return OcrResultModel(
      extractedText: extractedText ?? this.extractedText,
      merchantName: merchantName ?? this.merchantName,
      totalAmount: totalAmount ?? this.totalAmount,
      category: category ?? this.category,
      currency: currency ?? this.currency,
      date: date ?? this.date,
    );
  }
}
