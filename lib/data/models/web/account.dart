/// Wallet / account types supported by SakuKu.
enum AccountType {
  cash,
  bank,
  eWallet,
  creditCard,
  savings,
}

class Account {
  int id = 0;

  late String name;
  late AccountType type;
  late String icon;
  late String colorHex;
  late double initialBalance;
  late double currentBalance;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  bool isArchived = false;
}
