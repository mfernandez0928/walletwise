import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/account_model.dart';
import '../constants/account_types.dart';

class AccountProvider extends ChangeNotifier {
  late Box<Map> _accountsBox;
  List<Account> _accounts = [];
  String _baseCurrency = 'PHP';
  String? _currentUserId;

  // Filter and visibility states
  String _activeFilter = 'All';
  bool _showAmounts = true;

  List<Account> get accounts => _accounts;
  String get baseCurrency => _baseCurrency;
  String get activeFilter => _activeFilter;
  bool get showAmounts => _showAmounts;

  double get totalBalance {
    return CurrencyConverter.getTotalBalance(
      accounts: _accounts,
      targetCurrency: _baseCurrency,
    );
  }

  double get totalNetWorth => totalBalance; // Alias

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

  Future<void> _initializeBox() async {
    try {
      _accountsBox = await Hive.openBox<Map>('accounts');
      await _loadAccounts();
    } catch (e) {
      print('Error initializing accounts box: $e');
    }
  }

  Future<void> _loadAccounts() async {
    try {
      _accounts = _accountsBox.values
          .map((item) => Account.fromMap(item.cast<String, dynamic>()))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error loading accounts: $e');
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

      await _accountsBox.put(account.id, account.toMap());
      _accounts.add(account);
      notifyListeners();
    } catch (e) {
      print('Error adding account: $e');
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

/// Currency Converter Utility
class CurrencyConverter {
  // Exchange rates (Base: PHP = 1.0)
  static const Map<String, double> exchangeRates = {
    'PHP': 1.0,
    'USD': 55.0, // 1 USD = 55 PHP
    'EUR': 60.0, // 1 EUR = 60 PHP
    'GBP': 70.0, // 1 GBP = 70 PHP
    'JPY': 0.37, // 1 JPY = 0.37 PHP
    'CNY': 7.5, // 1 CNY = 7.5 PHP
    'INR': 0.65, // 1 INR = 0.65 PHP
    'THB': 1.5, // 1 THB = 1.5 PHP
    'SGD': 40.0, // 1 SGD = 40 PHP
    'MYR': 12.0, // 1 MYR = 12 PHP
    'IDR': 0.0035, // 1 IDR = 0.0035 PHP
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

    // Convert from source to base (PHP), then to target
    final inBase = amount * fromRate; // amount in EUR × rate = PHP
    final inTarget = inBase / toRate; // PHP / target rate = target currency

    return inTarget;
  }

  /// Get total balance of all accounts in target currency
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

  /// Format currency amount
  static String format(double amount, String currency) {
    final symbol = getCurrencySymbol(currency);
    return '$symbol ${amount.toStringAsFixed(2)}';
  }

  /// Get currency symbol
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
