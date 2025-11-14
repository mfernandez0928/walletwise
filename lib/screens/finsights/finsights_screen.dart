import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/account_provider.dart';
import '../../models/transaction_model.dart';
import '../../constants/app_colors.dart';
import '../../widgets/modern_card.dart';
import '../../services/export_service.dart';

class FinSightsScreen extends StatefulWidget {
  const FinSightsScreen({Key? key}) : super(key: key);

  @override
  State<FinSightsScreen> createState() => _FinSightsScreenState();
}

class _FinSightsScreenState extends State<FinSightsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentMonth = DateTime.now();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinSights Pro'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Charts'),
              Tab(text: 'Reports'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildChartsTab(),
          _buildReportsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer2<TransactionProvider, AccountProvider>(
      builder: (context, transactionProvider, accountProvider, _) {
        final monthTransactions =
            transactionProvider.getTransactionsByMonth(_currentMonth);

        final accountCurrencies = <String, List<Transaction>>{};
        for (var transaction in monthTransactions) {
          final account = accountProvider.getAccountById(transaction.accountId);
          if (account != null) {
            if (!accountCurrencies.containsKey(account.currency)) {
              accountCurrencies[account.currency] = [];
            }
            accountCurrencies[account.currency]!.add(transaction);
          }
        }

        double totalIncomeBase = 0;
        double totalExpenseBase = 0;

        for (var transaction in monthTransactions) {
          final account = accountProvider.getAccountById(transaction.accountId);
          if (account != null) {
            final convertedAmount = CurrencyConverter.convert(
              amount: transaction.amount,
              fromCurrency: account.currency,
              toCurrency: 'PHP',
            );

            if (transaction.type == TransactionType.income) {
              totalIncomeBase += convertedAmount;
            } else {
              totalExpenseBase += convertedAmount;
            }
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month Selector
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        setState(() {
                          _currentMonth = DateTime(
                            _currentMonth.year,
                            _currentMonth.month - 1,
                          );
                        });
                      },
                    ),
                    Text(
                      '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        setState(() {
                          _currentMonth = DateTime(
                            _currentMonth.year,
                            _currentMonth.month + 1,
                          );
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Summary Cards Row
              Row(
                children: [
                  Expanded(
                    child: ModernCard(
                      gradient: AppColors.successGradient,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Income',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₱${totalIncomeBase.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Converted to PHP',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ModernCard(
                      gradient: AppColors.warningGradient,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Expense',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₱${totalExpenseBase.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Converted to PHP',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Net Savings Card
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.secondary.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Net Savings (Converted to PHP)',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₱${(totalIncomeBase - totalExpenseBase).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: (totalIncomeBase - totalExpenseBase) >= 0
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: ((totalIncomeBase - totalExpenseBase) >= 0
                                    ? AppColors.success
                                    : AppColors.error)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            (totalIncomeBase - totalExpenseBase) >= 0
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            color: (totalIncomeBase - totalExpenseBase) >= 0
                                ? AppColors.success
                                : AppColors.error,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Currency Breakdown
              ...accountCurrencies.entries.map((currencyEntry) {
                final incomeInCurrency = currencyEntry.value
                    .where((t) => t.type == TransactionType.income)
                    .fold(0.0, (sum, t) => sum + t.amount);

                final expenseInCurrency = currencyEntry.value
                    .where((t) => t.type == TransactionType.expense)
                    .fold(0.0, (sum, t) => sum + t.amount);

                final symbol =
                    CurrencyConverter.getCurrencySymbol(currencyEntry.key);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  symbol,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              currencyEntry.key,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildCurrencyStatItem(
                              'Income',
                              '$symbol${incomeInCurrency.toStringAsFixed(2)}',
                              AppColors.success,
                            ),
                            _buildCurrencyStatItem(
                              'Expense',
                              '$symbol${expenseInCurrency.toStringAsFixed(2)}',
                              AppColors.error,
                            ),
                            _buildCurrencyStatItem(
                              'Net',
                              '$symbol${(incomeInCurrency - expenseInCurrency).toStringAsFixed(2)}',
                              (incomeInCurrency - expenseInCurrency) >= 0
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrencyStatItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildChartsTab() {
    return Consumer2<TransactionProvider, AccountProvider>(
      builder: (context, transactionProvider, accountProvider, _) {
        final monthTransactions =
            transactionProvider.getTransactionsByMonth(_currentMonth);

        final accountCurrencies = <String, List<Transaction>>{};
        for (var transaction in monthTransactions) {
          final account = accountProvider.getAccountById(transaction.accountId);
          if (account != null) {
            if (!accountCurrencies.containsKey(account.currency)) {
              accountCurrencies[account.currency] = [];
            }
            accountCurrencies[account.currency]!.add(transaction);
          }
        }

        double totalIncome = 0;
        double totalExpense = 0;

        for (var transaction in monthTransactions) {
          final account = accountProvider.getAccountById(transaction.accountId);
          if (account != null) {
            final convertedAmount = CurrencyConverter.convert(
              amount: transaction.amount,
              fromCurrency: account.currency,
              toCurrency: 'PHP',
            );

            if (transaction.type == TransactionType.income) {
              totalIncome += convertedAmount;
            } else {
              totalExpense += convertedAmount;
            }
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Income vs Expense (Converted to PHP)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.all(16),
                child: totalIncome == 0 && totalExpense == 0
                    ? const Center(
                        child: Text('No data available'),
                      )
                    : PieChart(
                        PieChartData(
                          sections: [
                            if (totalIncome > 0)
                              PieChartSectionData(
                                value: totalIncome,
                                title:
                                    '₱${(totalIncome / (totalIncome + totalExpense) * 100).toStringAsFixed(1)}%',
                                radius: 80,
                                color: AppColors.success,
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            if (totalExpense > 0)
                              PieChartSectionData(
                                value: totalExpense,
                                title:
                                    '₱${(totalExpense / (totalIncome + totalExpense) * 100).toStringAsFixed(1)}%',
                                radius: 80,
                                color: AppColors.error,
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Breakdown by Currency',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ...accountCurrencies.entries.map((currencyEntry) {
                final currencyIncome = currencyEntry.value
                    .where((t) => t.type == TransactionType.income)
                    .fold(0.0, (sum, t) => sum + t.amount);

                final currencyExpense = currencyEntry.value
                    .where((t) => t.type == TransactionType.expense)
                    .fold(0.0, (sum, t) => sum + t.amount);

                final symbol =
                    CurrencyConverter.getCurrencySymbol(currencyEntry.key);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currencyEntry.key,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Income: $symbol${currencyIncome.toStringAsFixed(0)} | Expense: $symbol${currencyExpense.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$symbol${(currencyIncome - currencyExpense).toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: (currencyIncome - currencyExpense) >= 0
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportsTab() {
    return Consumer2<TransactionProvider, AccountProvider>(
      builder: (context, transactionProvider, accountProvider, _) {
        final monthTransactions =
            transactionProvider.getTransactionsByMonth(_currentMonth);

        double totalIncome = 0;
        double totalExpense = 0;

        for (var transaction in monthTransactions) {
          final account = accountProvider.getAccountById(transaction.accountId);
          if (account != null) {
            final convertedAmount = CurrencyConverter.convert(
              amount: transaction.amount,
              fromCurrency: account.currency,
              toCurrency: 'PHP',
            );

            if (transaction.type == TransactionType.income) {
              totalIncome += convertedAmount;
            } else {
              totalExpense += convertedAmount;
            }
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Export & Reports',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await ExportService.exportToCSV(
                        monthTransactions,
                        'walletwise_${_currentMonth.month}_${_currentMonth.year}',
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✓ CSV exported to Documents folder'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Export as CSV'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await ExportService.exportToPDF(
                        monthTransactions,
                        'walletwise_${_currentMonth.month}_${_currentMonth.year}',
                        '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✓ PDF exported to Documents folder'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.file_present_rounded),
                  label: const Text('Export as PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Monthly Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryRow(
                      'Total Income',
                      '₱${totalIncome.toStringAsFixed(2)}',
                      AppColors.success,
                    ),
                    const Divider(height: 24),
                    _buildSummaryRow(
                      'Total Expense',
                      '₱${totalExpense.toStringAsFixed(2)}',
                      AppColors.error,
                    ),
                    const Divider(height: 24),
                    _buildSummaryRow(
                      'Net Savings',
                      '₱${(totalIncome - totalExpense).toStringAsFixed(2)}',
                      AppColors.primary,
                    ),
                    const Divider(height: 24),
                    _buildSummaryRow(
                      'Savings Rate',
                      totalIncome > 0
                          ? '${((totalIncome - totalExpense) / totalIncome * 100).toStringAsFixed(1)}%'
                          : '0%',
                      AppColors.info,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}
