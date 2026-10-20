import 'package:isar_community/isar.dart';

part 'account.g.dart';

/// Wallet / account types supported by SakuKu.
enum AccountType {
  cash,
  bank,
  eWallet,
  creditCard,
  savings,
}

@collection
class Account {
  Id id = Isar.autoIncrement;

  late String name;

  @enumerated
  late AccountType type;

  /// Lucide / Material icon key name (e.g. "wallet", "building").
  late String icon;

  /// Hex color without alpha, e.g. "#0D9488".
  late String colorHex;

  late double initialBalance;

  /// Cached balance; kept in sync when transactions change (Phase 2+).
  late double currentBalance;

  DateTime createdAt = DateTime.now();

  DateTime updatedAt = DateTime.now();

  bool isArchived = false;
}
