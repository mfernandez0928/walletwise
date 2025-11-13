import 'package:uuid/uuid.dart';
import '../constants/account_types.dart';

class Account {
  final String id;
  final String userId;
  final String name;
  final double balance;
  final String currency;
  final String currencySymbol;
  final String countryCode;
  final String bankId;
  final String bankName;
  final AccountType type;
  final String? emoji;
  final double? interestRate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Account({
    String? id,
    required this.userId,
    required this.name,
    required this.balance,
    required this.currency,
    required this.currencySymbol,
    required this.countryCode,
    required this.bankId,
    required this.bankName,
    required this.type,
    this.emoji,
    this.interestRate,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'balance': balance,
      'currency': currency,
      'currencySymbol': currencySymbol,
      'countryCode': countryCode,
      'bankId': bankId,
      'bankName': bankName,
      'type': type.toString(),
      'emoji': emoji,
      'interestRate': interestRate,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      balance: map['balance']?.toDouble() ?? 0.0,
      currency: map['currency'],
      currencySymbol: map['currencySymbol'],
      countryCode: map['countryCode'],
      bankId: map['bankId'],
      bankName: map['bankName'],
      type: _parseAccountType(map['type']),
      emoji: map['emoji'],
      interestRate: map['interestRate']?.toDouble(),
      createdAt:
          map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  static AccountType _parseAccountType(String type) {
    return AccountType.values.firstWhere(
      (e) => e.toString() == type,
      orElse: () => AccountType.wallet,
    );
  }

  /// Convert this account's balance to another currency
  double convertTo(String targetCurrency) {
    return CurrencyConverter.convert(
      amount: balance,
      fromCurrency: currency,
      toCurrency: targetCurrency,
    );
  }

  /// Format balance with currency symbol
  String formatBalance() {
    return '$currencySymbol ${balance.toStringAsFixed(2)}';
  }

  Account copyWith({
    String? name,
    double? balance,
    String? emoji,
    double? interestRate,
  }) {
    return Account(
      id: id,
      userId: userId,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      currency: currency,
      currencySymbol: currencySymbol,
      countryCode: countryCode,
      bankId: bankId,
      bankName: bankName,
      type: type,
      emoji: emoji ?? this.emoji,
      interestRate: interestRate ?? this.interestRate,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
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

    // Convert from source to PHP (base), then to target
    final inBase = amount / fromRate;
    final inTarget = inBase * toRate;

    return inTarget;
  }

  /// Get total balance of all accounts in a target currency
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
