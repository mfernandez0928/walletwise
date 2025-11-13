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
