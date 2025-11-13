import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/account_model.dart';
import '../constants/account_types.dart';
import '../services/currency_service.dart';

class AccountProvider extends ChangeNotifier {
  late Box<Map> _accountsBox;
  List<Account> _accounts = [];
  String _baseCurrency = 'PHP';
  String? _currentUserId;

  // Filter and visibility states
  String _activeFilter = 'All';
  bool _showAmounts = true;
  bool _isInitialized = false;

  List<Account> get accounts => _accounts;
  String get baseCurrency => _baseCurrency;
  String get activeFilter => _activeFilter;
  bool get showAmounts => _showAmounts;
  bool get isInitialized => _isInitialized;

  double get totalBalance {
    return CurrencyConverter.getTotalBalance(
      accounts: _accounts,
      targetCurrency: _baseCurrency,
    );
  }

  double get totalNetWorth => totalBalance;

  List<Account> get filteredAccounts {
    if (_activeFilter == 'All') {
      return _accounts;
    }
    return _accounts
        .where((a) => a.type.toString().split('.').last == _activeFilter)
        .toList();
  }

  AccountProvider() {
    _initializeBox();
  }

  // Call this after Firebase/Hive are initialized
  Future<void> init() async {
    await _initializeBox();
  }

  Future<void> _initializeBox() async {
    try {
      print('Opening Hive box for accounts...');
      _accountsBox = await Hive.openBox<Map>('accounts');
      print('Hive box opened successfully');

      await _loadAccounts();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing accounts box: $e');
      _isInitialized = false;
    }
  }

  Future<void> _loadAccounts() async {
    try {
      print('Loading accounts from Hive...');
      print('Box has ${_accountsBox.length} items');

      _accounts = _accountsBox.values
          .map((item) => Account.fromMap(item.cast<String, dynamic>()))
          .toList();

      print('✓ Loaded ${_accounts.length} accounts');
      for (var account in _accounts) {
        print('  - ${account.name} (${account.currency}): ${account.balance}');
      }

      notifyListeners();
    } catch (e) {
      print('✗ Error loading accounts: $e');
    }
  }

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  // Add account with all required fields
  Future<void> addAccount({
    required String name,
    required double balance,
    required String currency,
    required String currencySymbol,
    required String countryCode,
    required String bankId,
    required String bankName,
    required AccountType type,
    String? emoji,
    double? interestRate,
  }) async {
    try {
      final account = Account(
        userId: _currentUserId ?? 'default_user',
        name: name,
        balance: balance,
        currency: currency,
        currencySymbol: currencySymbol,
        countryCode: countryCode,
        bankId: bankId,
        bankName: bankName,
        type: type,
        emoji: emoji,
        interestRate: interestRate,
      );

      print('Adding account: ${account.name}');
      await _accountsBox.put(account.id, account.toMap());
      _accounts.add(account);
      print('✓ Account added successfully');
      notifyListeners();
    } catch (e) {
      print('✗ Error adding account: $e');
    }
  }

  Future<void> updateAccount({
    required String id,
    String? name,
    double? balance,
    String? emoji,
    double? interestRate,
  }) async {
    try {
      final index = _accounts.indexWhere((a) => a.id == id);
      if (index != -1) {
        final account = _accounts[index];
        final updated = account.copyWith(
          name: name,
          balance: balance,
          emoji: emoji,
          interestRate: interestRate,
        );

        await _accountsBox.put(id, updated.toMap());
        _accounts[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating account: $e');
    }
  }

  Future<void> deleteAccount(String id) async {
    try {
      await _accountsBox.delete(id);
      _accounts.removeWhere((a) => a.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting account: $e');
    }
  }

  // Filter methods
  void setFilter(String filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  List<Account> getAccountsByType(String type) {
    if (type == 'All') {
      return _accounts;
    }
    return _accounts
        .where((a) => a.type.toString().split('.').last == type)
        .toList();
  }

  // Visibility toggle
  void toggleAmountVisibility() {
    _showAmounts = !_showAmounts;
    notifyListeners();
  }

  // Currency methods
  void setBaseCurrency(String currency) {
    _baseCurrency = currency;
    notifyListeners();
  }

  double getBalance(String targetCurrency) {
    return CurrencyConverter.getTotalBalance(
      accounts: _accounts,
      targetCurrency: targetCurrency,
    );
  }

  Account? getAccountById(String id) {
    try {
      return _accounts.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get balance breakdown by type
  Map<String, double> getBalanceByType() {
    final breakdown = <String, double>{};
    for (var account in _accounts) {
      final type = account.type.toString().split('.').last;
      final balance = CurrencyConverter.convert(
        amount: account.balance,
        fromCurrency: account.currency,
        toCurrency: _baseCurrency,
      );
      breakdown[type] = (breakdown[type] ?? 0) + balance;
    }
    return breakdown;
  }
}

/// Updated Currency Converter with dynamic rates
class CurrencyConverter {
  static Map<String, double> _exchangeRates = {
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

  /// Initialize with real-time rates (call this on app startup)
  static Future<void> initialize() async {
    try {
      print('Initializing CurrencyConverter...');
      _exchangeRates = await CurrencyService.fetchExchangeRates();
      print('✓ Exchange rates loaded: $_exchangeRates');
    } catch (e) {
      print('✗ Error loading exchange rates: $e');
    }
  }

  /// Update rates (for manual refresh)
  static Future<void> updateRates() async {
    try {
      await CurrencyService.refreshRates();
      _exchangeRates = await CurrencyService.fetchExchangeRates();
      print('✓ Exchange rates refreshed');
    } catch (e) {
      print('✗ Error refreshing rates: $e');
    }
  }

  static double convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) {
    if (fromCurrency == toCurrency) return amount;

    final fromRate = _exchangeRates[fromCurrency] ?? 1.0;
    final toRate = _exchangeRates[toCurrency] ?? 1.0;

    // Convert from source to base (PHP), then to target
    final inBase = amount * fromRate;
    final inTarget = inBase / toRate;

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
    return '$symbol ${amount.toStringAsFixed(2)}';
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
