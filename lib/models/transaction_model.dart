import 'package:uuid/uuid.dart';

enum TransactionType { income, expense }

class Transaction {
  final String id;
  final String userId;
  final String description;
  final double amount;
  final String category;
  final String? source; // e.g., "Salary", "Freelance", "Business"
  final TransactionType type;
  final String accountId; // Which account this transaction belongs to
  final DateTime date;
  final String? icon;

  Transaction({
    String? id,
    required this.userId,
    required this.description,
    required this.amount,
    required this.category,
    this.source,
    required this.type,
    required this.accountId,
    DateTime? date,
    this.icon,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'description': description,
      'amount': amount,
      'category': category,
      'source': source,
      'type': type.toString().split('.').last,
      'accountId': accountId,
      'date': date.toIso8601String(),
      'icon': icon,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      userId: map['userId'],
      description: map['description'],
      amount: map['amount'],
      category: map['category'],
      source: map['source'],
      type: map['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      accountId: map['accountId'],
      date: DateTime.parse(map['date']),
      icon: map['icon'],
    );
  }

  Transaction copyWith({
    String? id,
    String? userId,
    String? description,
    double? amount,
    String? category,
    String? source,
    TransactionType? type,
    String? accountId,
    DateTime? date,
    String? icon,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      source: source ?? this.source,
      type: type ?? this.type,
      accountId: accountId ?? this.accountId,
      date: date ?? this.date,
      icon: icon ?? this.icon,
    );
  }
}
