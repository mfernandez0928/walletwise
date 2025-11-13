import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/account_provider.dart';
import '../../models/account_model.dart';
import '../../constants/app_colors.dart';
import '../../constants/account_types.dart';
import '../../constants/bank_data.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({Key? key}) : super(key: key);

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();

  String? _selectedCountry;
  String? _selectedBank;
  AccountType _selectedType = AccountType.wallet;
  String? _selectedEmoji;

  final _emojis = ['💰', '👛', '🏦', '💳', '📱', '🎯', '📈', '🌟'];

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _handleAddAccount() async {
    if (_nameController.text.isEmpty ||
        _selectedCountry == null ||
        _selectedBank == null ||
        _balanceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    // Find country data
    final country = BankData.countries.firstWhere(
      (c) => c['code'] == _selectedCountry,
    );

    // Find bank data
    final bank = (country['banks'] as List).firstWhere(
      (b) => b['id'] == _selectedBank,
    );

    final account = Account(
      userId: '', // Will be set from Firebase
      name: _nameController.text,
      balance: double.parse(_balanceController.text),
      currency: country['currency'],
      currencySymbol: country['symbol'],
      countryCode: country['code'],
      bankId: bank['id'],
      bankName: bank['name'],
      type: _selectedType,
      emoji: _selectedEmoji,
    );

    await context.read<AccountProvider>().addAccount(
          name: account.name,
          balance: account.balance,
          currency: account.currency,
          currencySymbol: account.currencySymbol,
          countryCode: account.countryCode,
          bankId: account.bankId,
          bankName: account.bankName,
          type: account.type,
          emoji: account.emoji,
          interestRate: account.interestRate,
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final selectedCountry = BankData.countries.firstWhere(
      (c) => c['code'] == _selectedCountry,
      orElse: () => {},
    );

    final banks = selectedCountry.isEmpty ? [] : selectedCountry['banks'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Name
            const Text(
              'Account Name',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'e.g., My Savings',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Country
            const Text(
              'Country',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCountry,
              items: BankData.countries.map<DropdownMenuItem<String>>((c) {
                return DropdownMenuItem<String>(
                  value: c['code'] as String,
                  child: Text('${c['flag']} ${c['name']}'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCountry = value;
                  _selectedBank = null;
                });
              },
              decoration: InputDecoration(
                hintText: 'Select country',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Bank
            if (_selectedCountry != null) ...[
              const Text(
                'Bank',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedBank,
                items: (banks as List).map<DropdownMenuItem<String>>((b) {
                  return DropdownMenuItem<String>(
                    value: b['id'] as String,
                    child: Text(b['name'] as String),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedBank = value);
                },
                decoration: InputDecoration(
                  hintText: 'Select bank',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Balance
            const Text(
              'Balance',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _balanceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0.00',
                prefixText: selectedCountry.isEmpty
                    ? ''
                    : '${selectedCountry['symbol']} ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Account Type
            const Text(
              'Account Type',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: AccountType.values.map((type) {
                final isSelected = _selectedType == type;
                return ChoiceChip(
                  label: Text(AccountTypeHelper.getLabel(type)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedType = type);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Emoji
            const Text(
              'Icon (Optional)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _emojis.map((emoji) {
                final isSelected = _selectedEmoji == emoji;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedEmoji = isSelected ? null : emoji);
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryLight
                          : AppColors.background,
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _handleAddAccount,
                child: const Text('Save Account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
