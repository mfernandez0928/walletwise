enum AccountType { wallet, savings, credit, investment, goals }

class AccountTypeHelper {
  static const Map<AccountType, String> labels = {
    AccountType.wallet: 'Wallet',
    AccountType.savings: 'Savings',
    AccountType.credit: 'Credit',
    AccountType.investment: 'Investment',
    AccountType.goals: 'Personal Goals',
  };

  static const Map<AccountType, String> emojis = {
    AccountType.wallet: '👛',
    AccountType.savings: '🏦',
    AccountType.credit: '💳',
    AccountType.investment: '📈',
    AccountType.goals: '🎯',
  };

  static String getLabel(AccountType type) => labels[type] ?? '';
  static String getEmoji(AccountType type) => emojis[type] ?? '';
}
