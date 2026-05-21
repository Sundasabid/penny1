// lib/core/utils/receipt_parser.dart

class ReceiptParseResult {
  final String merchantName;
  final double totalAmount;
  final String
  category; // grocery, transport, dining, shopping, bills, health, etc.
  final DateTime? date;
  final String currency;

  const ReceiptParseResult({
    required this.merchantName,
    required this.totalAmount,
    required this.category,
    required this.currency,
    this.date,
  });

  bool get isValid => merchantName.trim().isNotEmpty && totalAmount > 0;
}

class ReceiptParser {
  ReceiptParseResult parse(String rawText) {
    final normalized = _normalize(rawText);
    final lines = _lines(normalized);

    final currency = _detectCurrency(normalized);
    final date = _extractDate(lines);

    final merchantName = _extractMerchant(lines);
    final totalAmount = _extractTotal(lines);

    final category = _classifyCategory(
      lines: lines,
      merchantName: merchantName,
    );

    return ReceiptParseResult(
      merchantName: merchantName,
      totalAmount: totalAmount,
      category: category,
      currency: currency,
      date: date,
    );
  }

  // -------------------- Normalization --------------------

  String _normalize(String t) {
    if (t.trim().isEmpty) return "";
    return t
        .replaceAll('\r', '\n')
        .replaceAll('\u00A0', ' ')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .trim();
  }

  List<String> _lines(String t) {
    return t
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
  }

  // -------------------- Currency --------------------

  String _detectCurrency(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('pkr') ||
        lower.contains('rs ') ||
        lower.contains('rs.') ||
        lower.contains('rupee') ||
        lower.contains('rupees'))
      return 'PKR';
    if (lower.contains('usd') || lower.contains('\$')) return 'USD';
    if (lower.contains('aed')) return 'AED';
    if (lower.contains('sar')) return 'SAR';
    if (lower.contains('eur') || lower.contains('€')) return 'EUR';
    return 'PKR';
  }

  // -------------------- Date --------------------

  DateTime? _extractDate(List<String> lines) {
    final joined = lines.take(25).join(' ');

    final iso = RegExp(
      r'\b(20\d{2})[-\/\.](0?[1-9]|1[0-2])[-\/\.](0?[1-9]|[12]\d|3[01])\b',
    );
    final dmy = RegExp(
      r'\b(0?[1-9]|[12]\d|3[01])[-\/\.](0?[1-9]|1[0-2])[-\/\.](20\d{2})\b',
    );
    final mdy = RegExp(
      r'\b(0?[1-9]|1[0-2])[-\/\.](0?[1-9]|[12]\d|3[01])[-\/\.](20\d{2})\b',
    );

    Match? m = iso.firstMatch(joined);
    if (m != null)
      return _safeDate(
        int.parse(m.group(1)!),
        int.parse(m.group(2)!),
        int.parse(m.group(3)!),
      );

    m = dmy.firstMatch(joined);
    if (m != null)
      return _safeDate(
        int.parse(m.group(3)!),
        int.parse(m.group(2)!),
        int.parse(m.group(1)!),
      );

    m = mdy.firstMatch(joined);
    if (m != null)
      return _safeDate(
        int.parse(m.group(3)!),
        int.parse(m.group(1)!),
        int.parse(m.group(2)!),
      );

    return null;
  }

  DateTime? _safeDate(int y, int m, int d) {
    try {
      return DateTime(y, m, d);
    } catch (_) {
      return null;
    }
  }

  // -------------------- Merchant (IMPROVED) --------------------

  String _extractMerchant(List<String> lines) {
    // 1) If receipt explicitly says merchant/store/name, use that first.
    final explicit = _extractExplicitMerchant(lines);
    if (explicit != null) return explicit;

    // 2) Score top lines more intelligently.
    final candidates = <_ScoredText>[];
    final top = lines.take(18).toList();

    for (var i = 0; i < top.length; i++) {
      final raw = top[i];

      // Skip lines that are clearly not merchant candidates
      if (_looksLikeAddressOrContact(raw)) continue;
      if (_looksLikeMetaLine(raw)) continue;

      final cleaned = _cleanMerchantLine(raw);
      if (cleaned.isEmpty) continue;

      // Ignore too numeric
      if (_numericRatio(cleaned) > 0.30) continue;

      var score = 0;

      // Earlier lines get strong preference
      score += (30 - (i * 2)).clamp(0, 30);

      // Merchant lines often are short and "name-like"
      if (_isNameLike(cleaned)) score += 12;

      // Penalize generic words
      final lower = cleaned.toLowerCase();
      if (lower == 'store' || lower == 'mart' || lower == 'supermarket')
        score -= 10;

      // Penalize if it contains total keywords
      if (lower.contains('total') ||
          lower.contains('subtotal') ||
          lower.contains('vat') ||
          lower.contains('tax')) {
        score -= 10;
      }

      // Prefer if ALL CAPS (common on receipts)
      if (_isAllCaps(cleaned)) score += 6;

      // Prefer reasonable length
      if (cleaned.length >= 4 && cleaned.length <= 40) score += 6;
      if (cleaned.length > 50) score -= 8;

      candidates.add(_ScoredText(cleaned, score));
    }

    if (candidates.isEmpty) return "Unknown Merchant";
    candidates.sort((a, b) => b.score.compareTo(a.score));
    return candidates.first.text;
  }

  String? _extractExplicitMerchant(List<String> lines) {
    // Handles patterns:
    // "Merchant: XYZ"
    // "Store Name - XYZ"
    // "Shop: XYZ"
    final re = RegExp(
      r'^(merchant|store|store name|shop|outlet|branch)\s*[:\-]\s*(.+)$',
      caseSensitive: false,
    );

    for (final l in lines.take(25)) {
      final m = re.firstMatch(l.trim());
      if (m != null) {
        final v = _cleanMerchantLine(m.group(2) ?? '');
        if (v.isNotEmpty) return v;
      }
    }
    return null;
  }

  bool _looksLikeMetaLine(String line) {
    final lower = line.toLowerCase();
    final stop = <String>[
      'receipt',
      'tax invoice',
      'invoice',
      'thank you',
      'welcome',
      'cashier',
      'terminal',
      'pos',
      'ntn',
      'strn',
      'transaction',
      'auth',
      'approval',
      'visa',
      'mastercard',
      'debit',
      'credit',
      'served by',
      'customer',
      'copy',
      'refund',
      'return',
    ];

    if (stop.any(lower.contains)) return true;

    // skip lines dominated by symbols
    if (RegExp(r'^[\-\=\*_\.\s]+$').hasMatch(line)) return true;

    return false;
  }

  bool _looksLikeAddressOrContact(String line) {
    final lower = line.toLowerCase();

    // address / phone patterns
    if (lower.contains('tel') ||
        lower.contains('phone') ||
        lower.contains('mobile') ||
        lower.contains('address') ||
        lower.contains('street') ||
        lower.contains('road') ||
        lower.contains('plot') ||
        lower.contains('sector') ||
        lower.contains('block') ||
        lower.contains('phase') ||
        lower.contains('karachi') ||
        lower.contains('lahore') ||
        lower.contains('islamabad') ||
        lower.contains('rawalpindi') ||
        lower.contains('faisalabad')) {
      return true;
    }

    // phone numbers
    if (RegExp(r'\b0\d{2,4}[-\s]?\d{6,8}\b').hasMatch(line)) return true;

    return false;
  }

  String _cleanMerchantLine(String line) {
    // Keep safe characters.
    final s = line
        .replaceAll(RegExp("[^A-Za-z0-9\\s&\\-\\./']"), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return s
        .replaceAll(
          RegExp(
            r'^(merchant|store|store name|shop|name)\s*[:\-]\s*',
            caseSensitive: false,
          ),
          '',
        )
        .trim();
  }

  bool _isNameLike(String s) {
    if (s.length < 3) return false;
    final letters = RegExp(r'[A-Za-z]').allMatches(s).length;
    return (letters / s.length) > 0.55;
  }

  bool _isAllCaps(String s) {
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(s);
    if (!hasLetter) return false;
    return s.toUpperCase() == s && s.toLowerCase() != s;
  }

  double _numericRatio(String s) {
    final digits = RegExp(r'\d').allMatches(s).length;
    if (s.isEmpty) return 1;
    return digits / s.length;
  }

  // -------------------- Total (UNCHANGED) --------------------

  double _extractTotal(List<String> lines) {
    final candidates = <_TotalCandidate>[];

    final keywords = <String>[
      'grand total',
      'total due',
      'amount due',
      'balance due',
      'net total',
      'net amount',
      'total amount',
      'total',
      'payable',
      'amount payable',
    ];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lower = line.toLowerCase();

      final amounts = _extractMoneyAmounts(line);
      if (amounts.isEmpty) continue;

      for (final amt in amounts) {
        var score = 0;

        for (final k in keywords) {
          if (lower.contains(k)) {
            score += (k == 'total' ? 25 : 50);
            break;
          }
        }

        final fromBottom = (lines.length - 1) - i;
        if (fromBottom <= 12) score += (14 - fromBottom);

        if (lower.contains('subtotal')) score -= 14;
        if (lower.contains('change')) score -= 16;
        if (lower.contains('discount')) score -= 10;
        if (lower.contains('vat') || lower.contains('tax')) score -= 6;

        if (amt >= 1000) score += 4;

        candidates.add(_TotalCandidate(amount: amt, score: score));
      }
    }

    if (candidates.isEmpty) return 0;
    candidates.sort((a, b) => b.score.compareTo(a.score));
    return candidates.first.amount;
  }

  List<double> _extractMoneyAmounts(String line) {
    final re = RegExp(r'(?<!\d)(\d{1,3}(?:,\d{3})+|\d+)(?:\.(\d{1,2}))?(?!\d)');
    final matches = re.allMatches(line);

    final out = <double>[];
    for (final m in matches) {
      final whole = m.group(1) ?? '';
      final frac = m.group(2);
      final normalized =
          whole.replaceAll(',', '') + (frac != null ? '.$frac' : '');
      final val = double.tryParse(normalized);
      if (val != null && val > 0) out.add(val);
    }
    return out;
  }

  // -------------------- Category (IMPROVED) --------------------

  String _classifyCategory({
    required List<String> lines,
    required String merchantName,
  }) {
    final text = (merchantName + " " + lines.join(" ")).toLowerCase();

    // fuel/transport
    final transport = <String>[
      'fuel', 'petrol', 'diesel', 'cng', 'pump', 'filling', 'station',
      'shell', 'total parco', 'parco', 'attock', 'ps', 'pump station',
      'toll', 'parking', 'careem', 'uber', 'indrive', 'bykea', 'metrobus',
      'train', 'bus', 'ticket', 'ride',
      // common brands
      'euro oil', 'eurooil', 'hascol', 'go', 'pso', 'caltex',
    ];

    // grocery / supermarket
    final grocery = <String>[
      'mart',
      'super',
      'supermarket',
      'grocery',
      'cash & carry',
      'cash and carry',
      'metro',
      'carrefour',
      'imti',
      'imtiaz',
      'alfatah',
      'al fatah',
      'utility store',
      'fresh',
      'bakery',
      'fruit',
      'vegetable',
      'butcher',
      'meat',
      'milk',
      'eggs',
      'bread',
      'rice',
      'flour',
      'atta',
      'dal',
      'lentil',
    ];

    // dining
    final dining = <String>[
      'restaurant',
      'cafe',
      'coffee',
      'pizza',
      'burger',
      'biryani',
      'shawarma',
      'food',
      'bbq',
      'tea',
      'shake',
      'juice',
      'kfc',
      'mcdonald',
      'mcdonalds',
      'hardees',
      'subway',
      'cheezious',
      'dominos',
      'broadway',
      'krados',
      'optp',
    ];

    // shopping
    final shopping = <String>[
      'store',
      'mall',
      'outlet',
      'shop',
      'clothing',
      'apparel',
      'shoe',
      'brand',
      'garments',
      'boutique',
      'fashion',
      'cosmetics',
      'makeup',
      'electronics',
      'mobile',
      'accessories',
    ];

    // bills/utilities
    final bills = <String>[
      'electric',
      'electricity',
      'lesco',
      'iesco',
      'fesco',
      'gepco',
      'kepco',
      'k-electric',
      'kelectric',
      'gas',
      'ssgc',
      'sngpl',
      'water',
      'internet',
      'ptcl',
      'stormfiber',
      'nayatel',
      'jazz',
      'telenor',
      'ufone',
      'zong',
      'bill',
      'recharge',
      'topup',
    ];

    // health
    final health = <String>[
      'pharmacy',
      'medical',
      'clinic',
      'hospital',
      'lab',
      'diagnostic',
      'dawa',
      'medicine',
      'tablet',
      'capsule',
      'syrup',
    ];

    int score(List<String> keys) {
      var s = 0;
      for (final k in keys) {
        if (text.contains(k)) s++;
      }
      return s;
    }

    final sTransport = score(transport);
    final sGrocery = score(grocery);
    final sDining = score(dining);
    final sBills = score(bills);
    final sHealth = score(health);
    final sShopping = score(shopping);

    // Pick the highest score if meaningful
    final scores = <String, int>{
      'transport': sTransport,
      'grocery': sGrocery,
      'dining': sDining,
      'bills': sBills,
      'health': sHealth,
      'shopping': sShopping,
    };

    final best = scores.entries.reduce((a, b) => a.value >= b.value ? a : b);

    if (best.value >= 2)
      return best.key; // needs at least 2 hits to avoid random matches
    if (best.value == 1) {
      // single hit can still be useful if it is a strong keyword
      final strong = <String>{
        'pso',
        'hascol',
        'caltex',
        'euro oil',
        'kelectric',
        'k-electric',
        'sngpl',
        'ssgc',
        'kfc',
        'mcdonald',
        'mcdonalds',
        'cheezious',
        'metro',
        'carrefour',
        'alfatah',
        'al fatah',
      };
      if (strong.any((k) => text.contains(k))) return best.key;
    }

    return 'other';
  }
}

class _ScoredText {
  final String text;
  final int score;
  _ScoredText(this.text, this.score);
}

class _TotalCandidate {
  final double amount;
  final int score;
  _TotalCandidate({required this.amount, required this.score});
}
