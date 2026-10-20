import 'package:isar_community/isar.dart';

import '../../models/models.dart';
import '../isar_service.dart';

/// Seeds default accounts and categories on first launch.
class DatabaseSeeder {
  DatabaseSeeder({Isar? isar}) : _isar = isar ?? IsarService.instance.db;

  final Isar _isar;

  /// Runs once when both accounts and categories collections are empty.
  Future<void> seedIfEmpty() async {
    final accountCount = await _isar.accounts.count();
    final categoryCount = await _isar.categories.count();

    if (accountCount > 0 || categoryCount > 0) {
      await _ensureOtherIncomeCategory();
      return;
    }

    await _isar.writeTxn(() async {
      await _seedAccounts();
      await _seedCategories();
    });
  }

  Future<void> _ensureOtherIncomeCategory() async {
    final existing = await _isar.categories
        .filter()
        .nameEqualTo('Other')
        .typeEqualTo(CategoryType.income)
        .findFirst();
    if (existing != null) return;

    await _isar.writeTxn(() async {
      await _isar.categories.put(
        Category()
          ..name = 'Other'
          ..icon = 'wallet'
          ..colorHex = '#64748B'
          ..type = CategoryType.income
          ..isDefault = true,
      );
    });
  }

  Future<void> _seedAccounts() async {
    final now = DateTime.now();

    final cash = Account()
      ..name = 'Dompet Tunai'
      ..type = AccountType.cash
      ..icon = 'wallet'
      ..colorHex = '#0D9488'
      ..initialBalance = 500000
      ..currentBalance = 500000
      ..createdAt = now
      ..updatedAt = now;

    final bank = Account()
      ..name = 'Rekening Bank'
      ..type = AccountType.bank
      ..icon = 'landmark'
      ..colorHex = '#2563EB'
      ..initialBalance = 2500000
      ..currentBalance = 2500000
      ..createdAt = now
      ..updatedAt = now;

    final eWallet = Account()
      ..name = 'E-Wallet'
      ..type = AccountType.eWallet
      ..icon = 'smartphone'
      ..colorHex = '#7C3AED'
      ..initialBalance = 150000
      ..currentBalance = 150000
      ..createdAt = now
      ..updatedAt = now;

    await _isar.accounts.putAll([cash, bank, eWallet]);
  }

  Future<void> _seedCategories() async {
    final expenseDefaults = <({String name, String icon, String color})>[
      (name: 'Food & Drink', icon: 'utensils', color: '#EF4444'),
      (name: 'Transport', icon: 'car', color: '#F59E0B'),
      (name: 'Shopping', icon: 'shopping-bag', color: '#EC4899'),
      (name: 'Bills & Utilities', icon: 'zap', color: '#6366F1'),
      (name: 'Entertainment', icon: 'clapperboard', color: '#8B5CF6'),
    ];

    final incomeDefaults = <({String name, String icon, String color})>[
      (name: 'Salary', icon: 'briefcase', color: '#10B981'),
      (name: 'Freelance', icon: 'laptop', color: '#14B8A6'),
      (name: 'Investment', icon: 'trending-up', color: '#0EA5E9'),
      (name: 'Other', icon: 'wallet', color: '#64748B'),
    ];

    final categories = <Category>[
      for (final item in expenseDefaults)
        Category()
          ..name = item.name
          ..icon = item.icon
          ..colorHex = item.color
          ..type = CategoryType.expense
          ..isDefault = true,
      for (final item in incomeDefaults)
        Category()
          ..name = item.name
          ..icon = item.icon
          ..colorHex = item.color
          ..type = CategoryType.income
          ..isDefault = true,
    ];

    await _isar.categories.putAll(categories);
  }
}
