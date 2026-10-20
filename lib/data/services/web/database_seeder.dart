import '../../models/models.dart';
import 'memory_store.dart';

class DatabaseSeeder {
  DatabaseSeeder({Object? isar});

  Future<void> seedIfEmpty() async {
    final store = MemoryStore.instance;
    if (store.accounts.isNotEmpty || store.categories.isNotEmpty) {
      return;
    }
    await _seedAccounts(store);
    await _seedCategories(store);
  }

  Future<void> _seedAccounts(MemoryStore store) async {
    final now = DateTime.now();
    final seeds = [
      Account()
        ..id = store.nextAccountId()
        ..name = 'Dompet Tunai'
        ..type = AccountType.cash
        ..icon = 'wallet'
        ..colorHex = '#0D9488'
        ..initialBalance = 500000
        ..currentBalance = 500000
        ..createdAt = now
        ..updatedAt = now,
      Account()
        ..id = store.nextAccountId()
        ..name = 'Rekening Bank'
        ..type = AccountType.bank
        ..icon = 'landmark'
        ..colorHex = '#2563EB'
        ..initialBalance = 2500000
        ..currentBalance = 2500000
        ..createdAt = now
        ..updatedAt = now,
      Account()
        ..id = store.nextAccountId()
        ..name = 'E-Wallet'
        ..type = AccountType.eWallet
        ..icon = 'smartphone'
        ..colorHex = '#7C3AED'
        ..initialBalance = 150000
        ..currentBalance = 150000
        ..createdAt = now
        ..updatedAt = now,
    ];
    store.accounts.addAll(seeds);
  }

  Future<void> _seedCategories(MemoryStore store) async {
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
    ];

    for (final item in expenseDefaults) {
      store.categories.add(
        Category()
          ..id = store.nextCategoryId()
          ..name = item.name
          ..icon = item.icon
          ..colorHex = item.color
          ..type = CategoryType.expense
          ..isDefault = true,
      );
    }
    for (final item in incomeDefaults) {
      store.categories.add(
        Category()
          ..id = store.nextCategoryId()
          ..name = item.name
          ..icon = item.icon
          ..colorHex = item.color
          ..type = CategoryType.income
          ..isDefault = true,
      );
    }
  }
}
