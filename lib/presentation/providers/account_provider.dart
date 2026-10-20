import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/models.dart';
import 'repository_providers.dart';

part 'account_provider.g.dart';

/// All non-archived accounts with CRUD helpers.
@riverpod
class AccountList extends _$AccountList {
  @override
  Future<List<Account>> build() {
    return ref.watch(accountRepositoryProvider).getAll();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(accountRepositoryProvider).getAll(),
    );
  }

  Future<void> add(Account account) async {
    final repo = ref.read(accountRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.create(account);
      return repo.getAll();
    });
  }

  Future<void> updateAccount(Account account) async {
    final repo = ref.read(accountRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.update(account);
      return repo.getAll();
    });
  }

  Future<void> archive(int id) async {
    final repo = ref.read(accountRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.archive(id);
      return repo.getAll();
    });
  }

  Future<void> remove(int id) async {
    final repo = ref.read(accountRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.delete(id);
      return repo.getAll();
    });
  }
}

/// Alias-friendly single-account lookup.
@riverpod
Future<Account?> account(Ref ref, int id) {
  return ref.watch(accountRepositoryProvider).getById(id);
}

/// Sum of current balances across active accounts (net worth).
@riverpod
Future<double> totalNetWorth(Ref ref) async {
  final accounts = await ref.watch(accountListProvider.future);
  return accounts.fold<double>(0, (sum, a) => sum + a.currentBalance);
}
