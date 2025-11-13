import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrencyService {
  // Free API - no key needed!
  static const String _baseUrl =
      'https://api.exchangerate-api.com/v4/latest/PHP';
  static Map<String, double> _cachedRates = {};
  static DateTime? _lastFetch;

  /// Fetch real-time exchange rates (cached for 1 hour)
  static Future<Map<String, double>> fetchExchangeRates() async {
    // Return cached rates if fresh (less than 1 hour old)
    if (_cachedRates.isNotEmpty &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!).inMinutes < 60) {
      print('Using cached exchange rates');
      return _cachedRates;
    }

    try {
      print('Fetching live exchange rates...');
      final response = await http
          .get(Uri.parse(_baseUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Build rates map with PHP as base
        _cachedRates = {
          'PHP': 1.0,
        };

        final rates = data['rates'] as Map<String, dynamic>;

        // Only keep currencies we support
        final supportedCurrencies = [
          'USD',
          'EUR',
          'GBP',
          'JPY',
          'CNY',
          'INR',
          'THB',
          'SGD',
          'MYR',
          'IDR'
        ];

        rates.forEach((currency, rate) {
          if (supportedCurrencies.contains(currency)) {
            // Invert rates so PHP is base (1 PHP = X)
            _cachedRates[currency] = (1.0 / (rate as num)).toDouble();
          }
        });

        _lastFetch = DateTime.now();
        print('Exchange rates updated: $_cachedRates');
        return _cachedRates;
      } else {
        print('API Error: ${response.statusCode}');
        return _getDefaultRates();
      }
    } catch (e) {
      print('Error fetching exchange rates: $e');
      return _getDefaultRates();
    }
  }

  /// Default fallback rates (used if API fails)
  static Map<String, double> _getDefaultRates() {
    print('Using default exchange rates (API unavailable)');
    return {
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
  }

  /// Force refresh rates (call this manually when needed)
  static Future<void> refreshRates() async {
    _lastFetch = null; // Clear cache
    await fetchExchangeRates();
  }
}
