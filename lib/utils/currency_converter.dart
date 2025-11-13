class CurrencyConverter {
  // Exchange rates (1 unit = X PHP as base)
  static const Map<String, double> exchangeRates = {
    'PHP': 1.0,
    'USD': 55.0, // 1 USD = 55 PHP
    'EUR': 60.0, // 1 EUR = 60 PHP
    'GBP': 70.0, // 1 GBP = 70 PHP
    'JPY': 0.37, // 1 JPY = 0.37 PHP
  };

  /// Convert amount from one currency to another
  static double convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) {
    if (fromCurrency == toCurrency) return amount;

    final fromRate = exchangeRates[fromCurrency] ?? 1.0;
    final toRate = exchangeRates[toCurrency] ?? 1.0;

    // Convert to base (PHP), then to target
    return (amount / fromRate) * toRate;
  }

  /// Get total balance in a specific currency
  static double getTotalBalance({
    required List<Map<String, dynamic>> accounts,
    required String targetCurrency,
  }) {
    double total = 0;

    for (var account in accounts) {
      final balance = (account['balance'] ?? 0).toDouble();
      final currency = account['currency'] ?? 'USD';

      total += convert(
        amount: balance,
        fromCurrency: currency,
        toCurrency: targetCurrency,
      );
    }

    return total;
  }

  /// Format currency nicely
  static String format(double amount, String currency) {
    return '$currency ${amount.toStringAsFixed(2)}';
  }
}
