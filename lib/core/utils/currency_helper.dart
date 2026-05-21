class CurrencyHelper {
  static final Map<String, String> _codeToSymbol = {
    'PKR': '\u20A8', // ₨
    'USD': r'$',
    'EUR': '\u20AC', // €
    'GBP': '\u00A3', // £
    'JPY': '\u00A5', // ¥
    'CAD': r'CA$',
    'AUD': r'AU$',
    'AED': '\u062F.\u0625', // د.إ
    'SAR': '\uFDFC', // ﷼
    'INR': '\u20B9', // ₹
    'SGD': r'S$',
    'CNY': '\u00A5', // ¥
    'CHF': 'Fr',
    'TRY': '\u20BA', // ₺
    'NZD': r'NZ$',
    'HKD': r'HK$',
    'SEK': 'kr',
    'NOK': 'kr',
    'RUB': '\u20BD', // ₽
    'BRL': r'R$',
    'KRW': '\u20A9', // ₩
    'ZAR': 'R',
    'MYR': 'RM',
    'IDR': 'Rp',
    'PHP': '\u20B1', // ₱
    'THB': '\u0E3F', // ฿
    'VND': '\u20AB', // ₫
    'BTC': '\u20BF', // ₿
    'ETH': 'Ξ',
  };

  static final Map<String, String> _codeToName = {
    'PKR': 'Pakistani Rupee',
    'USD': 'US Dollar',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'JPY': 'Japanese Yen',
    'CAD': 'Canadian Dollar',
    'AUD': 'Australian Dollar',
    'AED': 'UAE Dirham',
    'SAR': 'Saudi Riyal',
    'INR': 'Indian Rupee',
    'SGD': 'Singapore Dollar',
    'CNY': 'Chinese Yuan',
    'CHF': 'Swiss Franc',
    'TRY': 'Turkish Lira',
    'NZD': 'New Zealand Dollar',
    'HKD': 'Hong Kong Dollar',
    'SEK': 'Swedish Krona',
    'NOK': 'Norwegian Krone',
    'RUB': 'Russian Ruble',
    'BRL': 'Brazilian Real',
    'KRW': 'South Korean Won',
    'ZAR': 'South African Rand',
    'MYR': 'Malaysian Ringgit',
    'IDR': 'Indonesian Rupiah',
    'PHP': 'Philippine Peso',
    'THB': 'Thai Baht',
    'VND': 'Vietnamese Dong',
    'BTC': 'Bitcoin',
    'ETH': 'Ethereum',
  };

  static String getSymbol(String? code) {
    if (code == null || code.isEmpty) return _codeToSymbol['PKR']!;
    return _codeToSymbol[code.toUpperCase()] ?? code.toUpperCase();
  }

  static String getName(String code) {
    return _codeToName[code.toUpperCase()] ?? 'International Currency';
  }

  static List<String> getSupportedCurrencies() {
    return _codeToName.keys.toList()..sort();
  }
}
