import 'package:uuid/uuid.dart';

enum ExpenseCategory {
  food,
  transportation,
  utilities,
  entertainment,
  healthcare,
  shopping,
  education,
  other
}

class Expense {
  final String id;
  final String userId;
  final String accountId;
  final double amount;
  final ExpenseCategory category;
  final String? description;
  final DateTime date;
  final DateTime createdAt;

  Expense({
    String? id,
    required this.userId,
    required this.accountId,
    required this.amount,
    required this.category,
    this.description,
    DateTime? date,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'accountId': accountId,
      'amount': amount,
      'category': category.toString(),
      'description': description,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      userId: map['userId'],
      accountId: map['accountId'],
      amount: map['amount']?.toDouble() ?? 0.0,
      category: _parseCategory(map['category']),
      description: map['description'],
      date: DateTime.parse(map['date']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  static ExpenseCategory _parseCategory(String category) {
    return ExpenseCategory.values.firstWhere(
      (e) => e.toString() == category,
      orElse: () => ExpenseCategory.other,
    );
  }
}

class ExpenseCategoryHelper {
  static const Map<ExpenseCategory, String> labels = {
    ExpenseCategory.food: 'Food & Dining',
    ExpenseCategory.transportation: 'Transportation',
    ExpenseCategory.utilities: 'Utilities',
    ExpenseCategory.entertainment: 'Entertainment',
    ExpenseCategory.healthcare: 'Healthcare',
    ExpenseCategory.shopping: 'Shopping',
    ExpenseCategory.education: 'Education',
    ExpenseCategory.other: 'Other',
  };

  static const Map<ExpenseCategory, String> emojis = {
    ExpenseCategory.food: '🍔',
    ExpenseCategory.transportation: '🚗',
    ExpenseCategory.utilities: '💡',
    ExpenseCategory.entertainment: '🎬',
    ExpenseCategory.healthcare: '🏥',
    ExpenseCategory.shopping: '🛍️',
    ExpenseCategory.education: '📚',
    ExpenseCategory.other: '📌',
  };
}
