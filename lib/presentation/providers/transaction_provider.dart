import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/models.dart';
import '../../data/repositories/transaction_repository.dart';
import 'account_provider.dart';
import 'analytics_provider.dart';
import 'budget_provider.dart';
import 'repository_providers.dart';

part 'transaction_provider.g.dart';

DateTime _monthStart([DateTime? from]) {
  final d = from ?? DateTime.now();
  return DateTime(d.year, d.month, 1);
}

DateTime _monthEnd([DateTime? from]) {
  final d = from ?? DateTime.now();
  return DateTime(d.year, d.month + 1, 0, 23, 59, 59);
}

/// Active transaction list filters (date range, account, category, type).
@riverpod
class TransactionFilterNotifier extends _$TransactionFilterNotifier {
  @override
  TransactionFilter build() {
    return TransactionFilter(
      start: _monthStart(),
      end: _monthEnd(),
    );
  }

  void setDateRange({DateTime? start, DateTime? end}) {
    state = TransactionFilter(
      start: start ?? state.start,
      end: end ?? state.end,
      accountId: state.accountId,
      categoryId: state.categoryId,
      type: state.type,
    );
  }

  void setAccount(int? accountId) {
    state = TransactionFilter(
      start: state.start,
      end: state.end,
      accountId: accountId,
      categoryId: state.categoryId,
      type: state.type,
    );
  }

  void setCategory(int? categoryId) {
    state = TransactionFilter(
      start: state.start,
      end: state.end,
      accountId: state.accountId,
      categoryId: categoryId,
      type: state.type,
    );
  }

  void setType(TransactionType? type) {
    state = TransactionFilter(
      start: state.start,
      end: state.end,
      accountId: state.accountId,
      categoryId: state.categoryId,
      type: type,
    );
  }

  void resetToCurrentMonth() {
    state = TransactionFilter(
      start: _monthStart(),
      end: _monthEnd(),
    );
  }

  void clear() {
    state = const TransactionFilter();
  }
}

/// Filtered transaction list with add / update / delete.
///
/// Mutations refresh account balances and invalidate analytics / budgets.
@riverpod
class TransactionList extends _$TransactionList {
  @override
  Future<List<Transaction>> build() {
    final filter = ref.watch(transactionFilterProvider);
    return ref.watch(transactionRepositoryProvider).getFiltered(filter);
  }

  Future<void> refresh() async {
    final filter = ref.read(transactionFilterProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(transactionRepositoryProvider).getFiltered(filter),
    );
  }

  Future<void> add(Transaction tx) async {
    await _mutate(() => ref.read(transactionRepositoryProvider).add(tx));
  }

  Future<void> updateTransaction(Transaction tx) async {
    await _mutate(() => ref.read(transactionRepositoryProvider).update(tx));
  }

  Future<void> remove(int id) async {
    await _mutate(() => ref.read(transactionRepositoryProvider).delete(id));
  }

  Future<void> _mutate(Future<void> Function() action) async {
    final filter = ref.read(transactionFilterProvider);
    final repo = ref.read(transactionRepositoryProvider);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await action();
      _invalidateRelated();
      return repo.getFiltered(filter);
    });
  }

  void _invalidateRelated() {
    ref.invalidate(accountListProvider);
    ref.invalidate(totalNetWorthProvider);
    ref.invalidate(budgetStatusesProvider);
    ref.invalidate(monthlyCashFlowProvider);
    ref.invalidate(boncosInspectorProvider);
    ref.invalidate(expenseBreakdownProvider);
    ref.invalidate(criticalBudgetAlertsProvider);
    ref.invalidate(recentTransactionsProvider);
  }
}

/// Latest transactions regardless of the active filter (dashboard strip).
@riverpod
Future<List<Transaction>> recentTransactions(Ref ref, {int limit = 20}) {
  return ref.watch(transactionRepositoryProvider).getRecent(limit: limit);
}

@riverpod
Future<Transaction?> transaction(Ref ref, int id) {
  return ref.watch(transactionRepositoryProvider).getById(id);
}
