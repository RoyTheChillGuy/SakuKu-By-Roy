import 'package:isar_community/isar.dart';

import '../../models/models.dart';
import '../isar_service.dart';
import 'database_seeder.dart';

/// Wipe / recalibrate local Isar data.
class DatabaseMaintenance {
  DatabaseMaintenance({Isar? isar}) : _isar = isar ?? IsarService.instance.db;

  final Isar _isar;

  Future<void> wipeAllAndReseed() async {
    await _isar.writeTxn(() async {
      await _isar.transactions.clear();
      await _isar.budgets.clear();
      await _isar.accounts.clear();
      await _isar.categories.clear();
    });
    await DatabaseSeeder(isar: _isar).seedIfEmpty();
  }

  /// Clears transactions & budgets and zeroes every account balance.
  Future<void> recalibrateBalances() async {
    await _isar.writeTxn(() async {
      await _isar.transactions.clear();
      await _isar.budgets.clear();

      final accounts = await _isar.accounts.where().findAll();
      final now = DateTime.now();
      for (final account in accounts) {
        account
          ..initialBalance = 0
          ..currentBalance = 0
          ..updatedAt = now;
        await _isar.accounts.put(account);
      }
    });
  }
}
