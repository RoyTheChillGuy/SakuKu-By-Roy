import '../../models/models.dart';
import '../../services/web/memory_store.dart';
import '../transaction_filter.dart';
import 'account_repository.dart';

export '../transaction_filter.dart';

class TransactionRepository {
  TransactionRepository({
    Object? isar,
    AccountRepository? accountRepository,
  }) : _accounts = accountRepository ?? AccountRepository();

  final AccountRepository _accounts;
  MemoryStore get _store => MemoryStore.instance;

  Future<Transaction?> getById(int id) async {
    for (final t in _store.transactions) {
      if (t.id == id) return t;
    }
    return null;
  }

  Future<List<Transaction>> getRecent({int limit = 20}) async {
    final list = List<Transaction>.from(_store.transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    return list.take(limit).toList();
  }

  Future<List<Transaction>> getAll() async {
    final list = List<Transaction>.from(_store.transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<List<Transaction>> getFiltered(TransactionFilter filter) async {
    Iterable<Transaction> list = _store.transactions;

    if (filter.start != null) {
      list = list.where(
        (t) => !t.date.isBefore(filter.start!),
      );
    }
    if (filter.end != null) {
      list = list.where((t) => !t.date.isAfter(filter.end!));
    }
    if (filter.accountId != null) {
      final id = filter.accountId!;
      list = list.where(
        (t) => t.accountId == id || t.targetAccountId == id,
      );
    }
    if (filter.categoryId != null) {
      list = list.where((t) => t.categoryId == filter.categoryId);
    }
    if (filter.type != null) {
      list = list.where((t) => t.type == filter.type);
    }

    final result = list.toList()..sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  Future<List<Transaction>> getByDateRange(DateTime start, DateTime end) {
    return getFiltered(TransactionFilter(start: start, end: end));
  }

  Future<int> add(Transaction tx) async {
    _validate(tx);
    tx.id = _store.nextTransactionId();
    tx.createdAt = DateTime.now();
    tx.updatedAt = DateTime.now();
    _store.transactions.add(tx);
    await _accounts.applyTransactionEffects(tx);
    return tx.id;
  }

  Future<int> update(Transaction tx) async {
    _validate(tx);
    final existing = await getById(tx.id);
    if (existing == null) {
      throw StateError('Transaction ${tx.id} not found.');
    }
    tx.updatedAt = DateTime.now();
    await _accounts.applyTransactionEffects(existing, reverse: true);
    final index = _store.transactions.indexWhere((t) => t.id == tx.id);
    if (index >= 0) {
      _store.transactions[index] = tx;
    }
    await _accounts.applyTransactionEffects(tx);
    return tx.id;
  }

  Future<bool> delete(int id) async {
    final existing = await getById(id);
    if (existing == null) return false;
    await _accounts.applyTransactionEffects(existing, reverse: true);
    _store.transactions.removeWhere((t) => t.id == id);
    return true;
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
