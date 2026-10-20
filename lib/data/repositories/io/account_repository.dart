import 'package:isar_community/isar.dart';

import '../../models/models.dart';
import '../../services/isar_service.dart';

/// CRUD and balance adjustments for [Account] wallets.
class AccountRepository {
  AccountRepository({Isar? isar}) : _isar = isar ?? IsarService.instance.db;

  final Isar _isar;

  Future<List<Account>> getAll({bool includeArchived = false}) async {
    if (includeArchived) {
      return _isar.accounts.where().sortByName().findAll();
    }
    return _isar.accounts
        .filter()
        .isArchivedEqualTo(false)
        .sortByName()
        .findAll();
  }

  Future<Account?> getById(Id id) => _isar.accounts.get(id);

  Future<Id> create(Account account) async {
    account.createdAt = DateTime.now();
    account.updatedAt = DateTime.now();
    account.currentBalance = account.initialBalance;
    return _isar.writeTxn(() => _isar.accounts.put(account));
  }

  Future<Id> update(Account account) async {
    account.updatedAt = DateTime.now();
    return _isar.writeTxn(() => _isar.accounts.put(account));
  }

  Future<bool> archive(Id id) async {
    return _isar.writeTxn(() async {
      final account = await _isar.accounts.get(id);
      if (account == null) return false;
      account.isArchived = true;
      account.updatedAt = DateTime.now();
      await _isar.accounts.put(account);
      return true;
    });
  }

  Future<bool> delete(Id id) async {
    return _isar.writeTxn(() => _isar.accounts.delete(id));
  }

  /// Applies income / expense / transfer balance effects.
  ///
  /// Must be called **inside** an active `isar.writeTxn`.
  Future<void> applyTransactionEffects(
    Transaction tx, {
    bool reverse = false,
  }) async {
    final sign = reverse ? -1.0 : 1.0;

    switch (tx.type) {
      case TransactionType.income:
        await _adjustBalance(tx.accountId, tx.amount * sign);
      case TransactionType.expense:
        await _adjustBalance(tx.accountId, -tx.amount * sign);
      case TransactionType.transfer:
        final fee = tx.transferFee ?? 0;
        await _adjustBalance(tx.accountId, -(tx.amount + fee) * sign);
        final targetId = tx.targetAccountId;
        if (targetId != null) {
          await _adjustBalance(targetId, tx.amount * sign);
        }
    }
  }

  Future<void> _adjustBalance(Id accountId, double delta) async {
    final account = await _isar.accounts.get(accountId);
    if (account == null) {
      throw StateError('Account $accountId not found while updating balance.');
    }
    account.currentBalance += delta;
    account.updatedAt = DateTime.now();
    await _isar.accounts.put(account);
  }

  /// Sum of non-archived account balances.
  Future<double> totalBalance() async {
    final accounts = await getAll();
    return accounts.fold<double>(0, (sum, a) => sum + a.currentBalance);
  }
}
