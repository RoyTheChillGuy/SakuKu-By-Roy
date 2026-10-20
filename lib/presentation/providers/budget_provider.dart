import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/models.dart';
import '../../data/repositories/budget_repository.dart';
import 'repository_providers.dart';

part 'budget_provider.g.dart';

/// Selected calendar month for budget views (defaults to now).
@riverpod
class BudgetPeriod extends _$BudgetPeriod {
  @override
  ({int month, int year}) build() {
    final now = DateTime.now();
    return (month: now.month, year: now.year);
  }

  void setPeriod({required int month, required int year}) {
    state = (month: month, year: year);
  }

  void goToCurrentMonth() {
    final now = DateTime.now();
    state = (month: now.month, year: now.year);
  }
}

/// Monthly budgets with live spending progress ([BudgetStatus]).
@riverpod
class BudgetStatuses extends _$BudgetStatuses {
  @override
  Future<List<BudgetStatus>> build() async {
    final period = ref.watch(budgetPeriodProvider);
    final repo = ref.watch(budgetRepositoryProvider);
    final budgets = await repo.getForMonth(
      month: period.month,
      year: period.year,
    );
    return Future.wait(budgets.map(repo.checkStatus));
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> add(Budget budget) async {
    final repo = ref.read(budgetRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.create(budget);
      return _load();
    });
  }

  Future<void> updateBudget(Budget budget) async {
    final repo = ref.read(budgetRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.update(budget);
      return _load();
    });
  }

  Future<void> remove(int id) async {
    final repo = ref.read(budgetRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.delete(id);
      return _load();
    });
  }

  Future<List<BudgetStatus>> _load() async {
    final period = ref.read(budgetPeriodProvider);
    final repo = ref.read(budgetRepositoryProvider);
    final budgets = await repo.getForMonth(
      month: period.month,
      year: period.year,
    );
    return Future.wait(budgets.map(repo.checkStatus));
  }
}

/// Budgets that crossed their alert threshold this period.
@riverpod
Future<List<BudgetStatus>> budgetAlerts(Ref ref) async {
  final period = ref.watch(budgetPeriodProvider);
  return ref.watch(budgetRepositoryProvider).getAlerts(
        month: period.month,
        year: period.year,
      );
}
