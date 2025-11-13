import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../constants/account_types.dart';

class AccountProvider extends ChangeNotifier {
  List<Account> _accounts = [];
  String _activeFilter = 'All';
  bool _showAmounts = true;

  List<Account> get accounts => _accounts;
  String get activeFilter => _activeFilter;
  bool get showAmounts => _showAmounts;

  List<Account> get filteredAccounts {
    if (_activeFilter == 'All') return _accounts;
    return _accounts.where((acc) {
      return AccountTypeHelper.labels[acc.type] == _activeFilter;
    }).toList();
  }

  double get totalNetWorth {
    return _accounts.fold(0, (sum, acc) => sum + acc.balance);
  }

  // Add account
  void addAccount(Account account) {
    _accounts.add(account);
    notifyListeners();
  }

  // Update account
  void updateAccount(String id, Account account) {
    final index = _accounts.indexWhere((acc) => acc.id == id);
    if (index >= 0) {
      _accounts[index] = account;
      notifyListeners();
    }
  }

  // Delete account
  void deleteAccount(String id) {
    _accounts.removeWhere((acc) => acc.id == id);
    notifyListeners();
  }

  // Set filter
  void setFilter(String filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  // Toggle amount visibility
  void toggleAmountVisibility() {
    _showAmounts = !_showAmounts;
    notifyListeners();
  }

  // Get account by ID
  Account? getAccountById(String id) {
    try {
      return _accounts.firstWhere((acc) => acc.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get accounts by type
  List<Account> getAccountsByType(AccountType type) {
    return _accounts.where((acc) => acc.type == type).toList();
  }
}
