import 'database_seeder.dart';
import 'memory_store.dart';

class DatabaseMaintenance {
  DatabaseMaintenance();

  MemoryStore get _store => MemoryStore.instance;

  Future<void> wipeAllAndReseed() async {
    _store.clearAllData();
    await DatabaseSeeder().seedIfEmpty();
  }

  Future<void> recalibrateBalances() async {
    _store.transactions.clear();
    _store.budgets.clear();
    final now = DateTime.now();
    for (final account in _store.accounts) {
      account
        ..initialBalance = 0
        ..currentBalance = 0
        ..updatedAt = now;
    }
  }
}
