import 'package:isar_community/isar.dart';

import '../../models/models.dart';
import '../../services/isar_service.dart';
import '../transaction_filter.dart';
import 'account_repository.dart';

export '../transaction_filter.dart';

/// Add / edit / delete transactions and keep account balances in sync.
class TransactionRepository {
  TransactionRepository({
    Isar? isar,
    AccountRepository? accountRepository,
  })  : _isar = isar ?? IsarService.instance.db,
        _accounts = accountRepository ??
            AccountRepository(isar: isar ?? IsarService.instance.db);

  final Isar _isar;
  final AccountRepository _accounts;

  Future<Transaction?> getById(Id id) => _isar.transactions.get(id);

  Future<List<Transaction>> getRecent({int limit = 20}) {
    return _isar.transactions.where().sortByDateDesc().limit(limit).findAll();
  }

  Future<List<Transaction>> getAll() {
    return _isar.transactions.where().sortByDateDesc().findAll();
  }

  Future<List<Transaction>> getFiltered(TransactionFilter filter) async {
    var query = _isar.transactions.filter().idGreaterThan(0);

    if (filter.start != null && filter.end != null) {
      query = query.dateBetween(
        filter.start!,
        filter.end!,
        includeLower: true,
        includeUpper: true,
      );
    } else if (filter.start != null) {
      query = query.dateGreaterThan(filter.start!, include: true);
    } else if (filter.end != null) {
      query = query.dateLessThan(filter.end!, include: true);
    }

    if (filter.accountId != null) {
      final accountId = filter.accountId!;
      query = query.group(
        (q) => q
            .accountIdEqualTo(accountId)
            .or()
            .targetAccountIdEqualTo(accountId),
      );
    }

    if (filter.categoryId != null) {
      query = query.categoryIdEqualTo(filter.categoryId!);
    }

    if (filter.type != null) {
      query = query.typeEqualTo(filter.type!);
    }

    return query.sortByDateDesc().findAll();
  }

  Future<List<Transaction>> getByDateRange(DateTime start, DateTime end) {
    return getFiltered(TransactionFilter(start: start, end: end));
  }

  Future<Id> add(Transaction tx) async {
    _validate(tx);
    tx.createdAt = DateTime.now();
    tx.updatedAt = DateTime.now();

    return _isar.writeTxn(() async {
      final id = await _isar.transactions.put(tx);
      await _accounts.applyTransactionEffects(tx);
      return id;
    });
  }

  Future<Id> update(Transaction tx) async {
    _validate(tx);
    final existing = await _isar.transactions.get(tx.id);
    if (existing == null) {
      throw StateError('Transaction ${tx.id} not found.');
    }

    tx.updatedAt = DateTime.now();

    return _isar.writeTxn(() async {
      await _accounts.applyTransactionEffects(existing, reverse: true);
      final id = await _isar.transactions.put(tx);
      await _accounts.applyTransactionEffects(tx);
      return id;
    });
  }

  Future<bool> delete(Id id) async {
    return _isar.writeTxn(() async {
      final existing = await _isar.transactions.get(id);
      if (existing == null) return false;
      await _accounts.applyTransactionEffects(existing, reverse: true);
      return _isar.transactions.delete(id);
    });
  }

  Future<double> sumExpenses({
    required DateTime start,
    required DateTime end,
    int? categoryId,
  }) async {
    final list = await getFiltered(
      TransactionFilter(
        start: start,
        end: end,
        categoryId: categoryId,
        type: TransactionType.expense,
      ),
    );
    return list.fold<double>(0, (sum, t) => sum + t.amount);
  }

  Future<double> sumIncome({
    required DateTime start,
    required DateTime end,
  }) async {
    final list = await getFiltered(
      TransactionFilter(
        start: start,
        end: end,
        type: TransactionType.income,
      ),
    );
    return list.fold<double>(0, (sum, t) => sum + t.amount);
  }

  void _validate(Transaction tx) {
    if (tx.amount <= 0) {
      throw ArgumentError('Transaction amount must be greater than zero.');
    }
    if (tx.type == TransactionType.transfer && tx.targetAccountId == null) {
      throw ArgumentError('Transfer requires targetAccountId.');
    }
    if (tx.type == TransactionType.transfer &&
        tx.targetAccountId == tx.accountId) {
      throw ArgumentError('Cannot transfer to the same account.');
    }
  }
}
