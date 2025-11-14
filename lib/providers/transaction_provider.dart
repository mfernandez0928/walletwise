import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  late Box<Map> _transactionsBox;
  List<Transaction> _transactions = [];
  String? _currentUserId;

  List<Transaction> get transactions => _transactions;

  List<Transaction> get recentTransactions {
    final sorted = List<Transaction>.from(_transactions);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  double get totalIncome {
    return _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    return _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (sum, t) => sum + t.amount);
  }

  TransactionProvider() {
    _initializeBox();
  }

  Future<void> _initializeBox() async {
    try {
      _transactionsBox = await Hive.openBox<Map>('transactions');
      await _loadTransactions();
    } catch (e) {
      print('Error initializing transactions box: $e');
    }
  }

  Future<void> _loadTransactions() async {
    try {
      _transactions = _transactionsBox.values
          .map((item) => Transaction.fromMap(item.cast<String, dynamic>()))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error loading transactions: $e');
    }
  }

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  Future<void> addTransaction({
    required String description,
    required double amount,
    required String category,
    String? source,
    required TransactionType type,
    required String accountId,
    DateTime? date,
    String? icon,
  }) async {
    try {
      final transaction = Transaction(
        userId: _currentUserId ?? 'default_user',
        description: description,
        amount: amount,
        category: category,
        source: source,
        type: type,
        accountId: accountId,
        date: date,
        icon: icon,
      );

      await _transactionsBox.put(transaction.id, transaction.toMap());
      _transactions.add(transaction);
      notifyListeners();
    } catch (e) {
      print('Error adding transaction: $e');
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _transactionsBox.delete(id);
      _transactions.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting transaction: $e');
    }
  }

  List<Transaction> getTransactionsByCategory(String category) {
    return _transactions.where((t) => t.category == category).toList();
  }

  List<Transaction> getTransactionsByMonth(DateTime month) {
    return _transactions
        .where((t) => t.date.month == month.month && t.date.year == month.year)
        .toList();
  }
}
