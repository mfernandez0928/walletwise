class CurrencyConverter {
  static const Map<String, double> exchangeRates = {
    'PHP': 1.0,
    'USD': 55.0,
    'EUR': 60.0,
    'GBP': 70.0,
    'JPY': 0.37,
    'CNY': 7.5,
    'INR': 0.65,
    'THB': 1.5,
    'SGD': 40.0,
    'MYR': 12.0,
    'IDR': 0.0035,
  };

  static double convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) {
    if (fromCurrency == toCurrency) return amount;

    final fromRate = exchangeRates[fromCurrency] ?? 1.0;
    final toRate = exchangeRates[toCurrency] ?? 1.0;

    // FIX: Correct conversion logic
    final inBase = amount / fromRate; // Convert TO PHP (base)
    final inTarget = inBase * toRate; // Convert PHP TO target

    return inTarget;
  }

  static double getTotalBalance({
    required List<Account> accounts,
    required String targetCurrency,
  }) {
    double total = 0;
    for (var account in accounts) {
      total += convert(
        amount: account.balance,
        fromCurrency: account.currency,
        toCurrency: targetCurrency,
      );
    }
    return total;
  }

  static String format(double amount, String currency) {
    final symbol = getCurrencySymbol(currency);
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  static String getCurrencySymbol(String currency) {
    const symbols = {
      'PHP': '₱',
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
      'CNY': '¥',
      'INR': '₹',
      'THB': '฿',
      'SGD': 'S\$',
      'MYR': 'RM',
      'IDR': 'Rp',
    };
    return symbols[currency] ?? currency;
  }
}
