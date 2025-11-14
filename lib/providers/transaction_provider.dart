import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  late Box<Map> _transactionsBox;
  List<Transaction> _transactions = [];
  String? _currentUserId;
  bool _isInitialized = false;

  List<Transaction> get transactions => _transactions;
  bool get isInitialized => _isInitialized;

  List<Transaction> get recentTransactions {
    final sorted = List<Transaction>.from(_transactions);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  double get totalIncome {
    return _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    return _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  TransactionProvider() {
    _initializeBox();
  }

  // Call this after Firebase/Hive are initialized
  Future<void> init() async {
    await _initializeBox();
  }

  Future<void> _initializeBox() async {
    try {
      print('🔄 Opening Hive box for transactions...');
      _transactionsBox = await Hive.openBox<Map>('transactions');
      print('✓ Hive transactions box opened successfully');

      await _loadTransactions();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('✗ Error initializing transactions box: $e');
      _isInitialized = false;
    }
  }

  Future<void> _loadTransactions() async {
    try {
      print('🔄 Loading transactions from Hive...');
      print('Box has ${_transactionsBox.length} items');

      _transactions = _transactionsBox.values
          .map((item) => Transaction.fromMap(item.cast<String, dynamic>()))
          .toList();

      print('✓ Loaded ${_transactions.length} transactions');
      for (var transaction in _transactions) {
        print('  - ${transaction.description} (${transaction.amount})');
      }

      notifyListeners();
    } catch (e) {
      print('✗ Error loading transactions: $e');
    }
  }

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
    print('✓ Current user ID set to: $userId');
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
        date: date ?? DateTime.now(),
        icon: icon,
      );

      print('💾 Saving transaction: ${transaction.description}');
      await _transactionsBox.put(transaction.id, transaction.toMap());
      _transactions.add(transaction);

      print('✓ Transaction saved successfully (ID: ${transaction.id})');
      print('✓ Total transactions: ${_transactions.length}');

      notifyListeners();
    } catch (e) {
      print('✗ Error adding transaction: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      print('🗑️ Deleting transaction: $id');
      await _transactionsBox.delete(id);
      _transactions.removeWhere((t) => t.id == id);

      print('✓ Transaction deleted successfully');
      print('✓ Total transactions: ${_transactions.length}');

      notifyListeners();
    } catch (e) {
      print('✗ Error deleting transaction: $e');
      rethrow;
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

  // Force reload transactions from Hive
  Future<void> reloadTransactions() async {
    print('🔄 Force reloading transactions...');
    await _loadTransactions();
  }
}
