import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/account_provider.dart';
import '../../models/transaction_model.dart';
import '../../constants/app_colors.dart';

class AddTransactionScreen extends StatefulWidget {
  final String? accountId;
  const AddTransactionScreen({Key? key, this.accountId}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  TransactionType _selectedType = TransactionType.income;
  String _selectedCategory = 'Salary';
  String? _selectedSource;
  String? _selectedAccountId;

  final List<String> _incomeCategories = [
    'Salary',
    'Freelance',
    'Business',
    'Bonus',
    'Interest',
    'Gifts',
    'Other'
  ];

  final List<String> _expenseCategories = [
    'Food',
    'Transport',
    'Entertainment',
    'Shopping',
    'Bills',
    'Insurance',
    'Healthcare',
    'Education',
    'Other'
  ];

  final Map<String, String> _categoryIcons = {
    'Salary': '💼',
    'Freelance': '💻',
    'Business': '🏢',
    'Bonus': '🎉',
    'Interest': '📈',
    'Gifts': '🎁',
    'Food': '🍔',
    'Transport': '🚗',
    'Entertainment': '🎬',
    'Shopping': '🛍️',
    'Bills': '📄',
    'Insurance': '🛡️',
    'Healthcare': '⚕️',
    'Education': '📚',
    'Other': '📌'
  };

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _amountController = TextEditingController();
    _selectedAccountId = widget.accountId;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // Get selected account's currency symbol
  String _getSelectedCurrencySymbol() {
    if (_selectedAccountId == null) return '₱';

    final accountProvider = context.read<AccountProvider>();
    final account = accountProvider.getAccountById(_selectedAccountId!);

    if (account == null) return '₱';
    return CurrencyConverter.getCurrencySymbol(account.currency);
  }

  void _addTransaction() async {
    // Validation
    if (_descriptionController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields and select an account'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final accountProvider = context.read<AccountProvider>();
      final account = accountProvider.getAccountById(_selectedAccountId!);

      if (account == null) {
        throw Exception('Account not found');
      }

      // Calculate new balance
      late double newBalance;
      if (_selectedType == TransactionType.income) {
        newBalance = account.balance + amount;
      } else {
        newBalance = account.balance - amount;
        // Check for insufficient balance
        if (newBalance < 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Insufficient balance! Available: ${CurrencyConverter.getCurrencySymbol(account.currency)}${account.balance.toStringAsFixed(2)}',
              ),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
      }

      // Step 1: Add transaction to history
      context.read<TransactionProvider>().addTransaction(
            description: _descriptionController.text,
            amount: amount,
            category: _selectedCategory,
            source: _selectedSource ?? _selectedCategory,
            type: _selectedType,
            accountId: _selectedAccountId!,
            icon: _categoryIcons[_selectedCategory],
          );

      // Step 2: Update account balance
      await accountProvider.updateAccountBalance(
        accountId: _selectedAccountId!,
        newBalance: newBalance,
      );

      // Step 3: Show success message
      if (mounted) {
        final symbol = CurrencyConverter.getCurrencySymbol(account.currency);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_selectedType == TransactionType.income ? 'Income' : 'Expense'} added successfully!\n'
              'New Balance: $symbol${newBalance.toStringAsFixed(2)} ${account.currency}',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );

        // Step 4: Navigate back
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error adding transaction: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = _selectedType == TransactionType.income
        ? _incomeCategories
        : _expenseCategories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transaction Type Toggle
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(
                          () => _selectedType = TransactionType.income),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedType == TransactionType.income
                              ? AppColors.success
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Income',
                            style: TextStyle(
                              color: _selectedType == TransactionType.income
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(
                          () => _selectedType = TransactionType.expense),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedType == TransactionType.expense
                              ? AppColors.error
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Expense',
                            style: TextStyle(
                              color: _selectedType == TransactionType.expense
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Select Account
            const Text(
              'Select Account',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Consumer<AccountProvider>(
              builder: (context, accountProvider, _) {
                final accounts = accountProvider.accounts;
                if (accounts.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Text(
                      'No accounts available. Please create an account first.',
                      style: TextStyle(color: AppColors.error),
                    ),
                  );
                }

                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    underline: const SizedBox(),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    value: _selectedAccountId ?? accounts.first.id,
                    onChanged: (value) {
                      setState(() => _selectedAccountId = value);
                    },
                    items: accounts.map((account) {
                      final symbol =
                          CurrencyConverter.getCurrencySymbol(account.currency);

                      return DropdownMenuItem<String>(
                        value: account.id,
                        child: Row(
                          children: [
                            Text(
                              account.emoji ?? '💳',
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  account.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  '$symbol${account.balance.toStringAsFixed(2)} ${account.currency}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Description
            const Text(
              'Description',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'e.g., Monthly salary',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Amount - with dynamic currency symbol
            Text(
              'Amount (${_getSelectedCurrencySymbol()})',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              decoration: InputDecoration(
                hintText: '0.00',
                prefixText: '${_getSelectedCurrencySymbol()} ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Category
            const Text(
              'Category',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((category) {
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = category),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppColors.primary : AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _categoryIcons[category] ?? '📌',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          category,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Add Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _addTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add Transaction',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
