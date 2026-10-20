import '../../models/models.dart';
import '../../services/web/memory_store.dart';

class AccountRepository {
  AccountRepository({Object? isar});

  MemoryStore get _store => MemoryStore.instance;

  Future<List<Account>> getAll({bool includeArchived = false}) async {
    final list = includeArchived
        ? List<Account>.from(_store.accounts)
        : _store.accounts.where((a) => !a.isArchived).toList();
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  Future<Account?> getById(int id) async {
    for (final a in _store.accounts) {
      if (a.id == id) return a;
    }
    return null;
  }

  Future<int> create(Account account) async {
    account.id = _store.nextAccountId();
    account.createdAt = DateTime.now();
    account.updatedAt = DateTime.now();
    account.currentBalance = account.initialBalance;
    _store.accounts.add(account);
    return account.id;
  }

  Future<int> update(Account account) async {
    account.updatedAt = DateTime.now();
    final index = _store.accounts.indexWhere((a) => a.id == account.id);
    if (index >= 0) {
      _store.accounts[index] = account;
    }
    return account.id;
  }

  Future<bool> archive(int id) async {
    final account = await getById(id);
    if (account == null) return false;
    account.isArchived = true;
    account.updatedAt = DateTime.now();
    return true;
  }

  Future<bool> delete(int id) async {
    final before = _store.accounts.length;
    _store.accounts.removeWhere((a) => a.id == id);
    return _store.accounts.length < before;
  }

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

  Future<void> _adjustBalance(int accountId, double delta) async {
    final account = await getById(accountId);
    if (account == null) {
      throw StateError('Account $accountId not found while updating balance.');
    }
    account.currentBalance += delta;
    account.updatedAt = DateTime.now();
  }

  Future<double> totalBalance() async {
    final accounts = await getAll();
    return accounts.fold<double>(0, (sum, a) => sum + a.currentBalance);
  }
}
