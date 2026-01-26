class ParsedReceipt {
  final String merchant;
  final double amount;
  final DateTime date;
  final String category;

  const ParsedReceipt({
    required this.merchant,
    required this.amount,
    required this.date,
    required this.category,
  });
}

class ReceiptParser {
  const ReceiptParser();

  ParsedReceipt parse(String rawText) {
    final normalized = rawText.replaceAll('\r', '');
    final lines = normalized
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final merchant = _extractMerchant(lines);
    final amount = _extractTotalAmount(normalized);
    final date = _extractDate(normalized) ?? DateTime.now();
    final category = _detectCategory(normalized.toLowerCase());

    return ParsedReceipt(
      merchant: merchant,
      amount: amount,
      date: date,
      category: category,
    );
  }

  String _extractMerchant(List<String> lines) {
    // Heuristic: first meaningful non-numeric line near the top
    for (final l in lines.take(6)) {
      final hasLetters = RegExp(r'[A-Za-z]').hasMatch(l);
      final looksLikeAmount = RegExp(r'\d+\.\d{2}').hasMatch(l);
      final tooShort = l.length < 3;
      if (hasLetters && !looksLikeAmount && !tooShort) {
        return l;
      }
    }
    return 'Unknown Merchant';
  }

  double _extractTotalAmount(String text) {
    // Try "TOTAL" line first (most reliable)
    final totalLineRegex = RegExp(
      r'(total|grand total|amount due|net total)\s*[:\-]?\s*(pkr|rs\.?|rupees)?\s*([0-9]{1,3}(?:,[0-9]{3})*(?:\.[0-9]{1,2})?)',
      caseSensitive: false,
    );

    final totalMatch = totalLineRegex.firstMatch(text);
    if (totalMatch != null) {
      final v = totalMatch.group(3);
      if (v != null) return _toDouble(v);
    }

    // Fallback: pick the largest currency-like number
    final amountRegex = RegExp(r'([0-9]{1,3}(?:,[0-9]{3})*(?:\.[0-9]{1,2})?)');
    final values = amountRegex
        .allMatches(text)
        .map((m) => m.group(0)!)
        .map(_toDouble)
        .where((v) => v > 0)
        .toList();

    if (values.isEmpty) return 0;
    values.sort();
    return values.last;
  }

  double _toDouble(String s) {
    final cleaned = s.replaceAll(',', '');
    return double.tryParse(cleaned) ?? 0;
  }

  DateTime? _extractDate(String text) {
    // Common receipt patterns: 2023-10-26, 26/10/2023, 10/26/2023
    final iso = RegExp(r'(\d{4})[-\/.](\d{1,2})[-\/.](\d{1,2})');
    final dmy = RegExp(r'(\d{1,2})[-\/.](\d{1,2})[-\/.](\d{2,4})');

    final m1 = iso.firstMatch(text);
    if (m1 != null) {
      final y = int.tryParse(m1.group(1)!) ?? 0;
      final mo = int.tryParse(m1.group(2)!) ?? 1;
      final d = int.tryParse(m1.group(3)!) ?? 1;
      if (y > 1900) return DateTime(y, mo, d);
    }

    final m2 = dmy.firstMatch(text);
    if (m2 != null) {
      final a = int.tryParse(m2.group(1)!) ?? 1;
      final b = int.tryParse(m2.group(2)!) ?? 1;
      var y = int.tryParse(m2.group(3)!) ?? 0;
      if (y < 100) y += 2000;

      // Heuristic: if first part > 12 -> treat as D/M/Y else ambiguous -> assume D/M/Y
      final day = a > 12 ? a : a;
      final month = a > 12 ? b : b;

      if (y > 1900) return DateTime(y, month, day);
    }

    return null;
  }

  String _detectCategory(String text) {
    // Simple keyword mapping (expand later)
    if (text.contains('fuel') || text.contains('petrol') || text.contains('diesel')) {
      return 'Transport';
    }
    if (text.contains('pharmacy') || text.contains('medicine') || text.contains('tablet')) {
      return 'Health';
    }
    if (text.contains('restaurant') || text.contains('cafe') || text.contains('coffee') || text.contains('burger')) {
      return 'Food & Drink';
    }
    if (text.contains('mart') || text.contains('grocery') || text.contains('super') || text.contains('imti') || text.contains('carrefour')) {
      return 'Groceries';
    }
    if (text.contains('daraz') || text.contains('store') || text.contains('outfit') || text.contains('mall')) {
      return 'Shopping';
    }
    return 'Other';
  }
}
