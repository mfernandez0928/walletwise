import 'package:flutter/material.dart';
import '../models/expense_model.dart';

class ExpenseProvider extends ChangeNotifier {
  List<Expense> _expenses = [];

  List<Expense> get expenses => _expenses;

  double get monthlyTotal {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.month == now.month && e.date.year == now.year)
        .fold(0, (sum, e) => sum + e.amount);
  }

  double get totalExpenses {
    return _expenses.fold(0, (sum, e) => sum + e.amount);
  }

  void addExpense(Expense expense) {
    _expenses.add(expense);
    notifyListeners();
  }

  void deleteExpense(String id) {
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  List<Expense> getExpensesByCategory(ExpenseCategory category) {
    return _expenses.where((e) => e.category == category).toList();
  }

  Map<ExpenseCategory, double> getCategoryTotals() {
    Map<ExpenseCategory, double> totals = {};
    for (var expense in _expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }
}
