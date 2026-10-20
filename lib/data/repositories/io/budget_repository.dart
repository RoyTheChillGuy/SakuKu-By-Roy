import 'package:isar_community/isar.dart';

import '../../models/models.dart';
import '../../services/isar_service.dart';
import '../budget_status.dart';
import 'transaction_repository.dart';

export '../budget_status.dart';

/// CRUD for monthly budgets and threshold checks.
class BudgetRepository {
  BudgetRepository({
    Isar? isar,
    TransactionRepository? transactionRepository,
  })  : _isar = isar ?? IsarService.instance.db,
        _transactions = transactionRepository ??
            TransactionRepository(isar: isar ?? IsarService.instance.db);

  final Isar _isar;
  final TransactionRepository _transactions;

  Future<List<Budget>> getAll() {
    return _isar.budgets.where().sortByYearDesc().thenByMonthDesc().findAll();
  }

  Future<List<Budget>> getForMonth({
    required int month,
    required int year,
  }) {
    return _isar.budgets
        .filter()
        .monthEqualTo(month)
        .and()
        .yearEqualTo(year)
        .findAll();
  }

  Future<Budget?> getById(Id id) => _isar.budgets.get(id);

  Future<Budget?> getOverallBudget({
    required int month,
    required int year,
  }) async {
    final budgets = await getForMonth(month: month, year: year);
    for (final budget in budgets) {
      if (budget.categoryId == null) return budget;
    }
    return null;
  }

  Future<Budget?> getCategoryBudget({
    required int categoryId,
    required int month,
    required int year,
  }) async {
    final budgets = await getForMonth(month: month, year: year);
    for (final budget in budgets) {
      if (budget.categoryId == categoryId) return budget;
    }
    return null;
  }

  Future<Id> create(Budget budget) {
    budget.createdAt = DateTime.now();
    return _isar.writeTxn(() => _isar.budgets.put(budget));
  }

  Future<Id> update(Budget budget) {
    return _isar.writeTxn(() => _isar.budgets.put(budget));
  }

  Future<bool> delete(Id id) {
    return _isar.writeTxn(() => _isar.budgets.delete(id));
  }

  Future<BudgetStatus> checkStatus(Budget budget) async {
    final start = DateTime(budget.year, budget.month, 1);
    final end = DateTime(budget.year, budget.month + 1, 0, 23, 59, 59);

    final spent = await _transactions.sumExpenses(
      start: start,
      end: end,
      categoryId: budget.categoryId,
    );

    final ratio =
        budget.amountLimit <= 0 ? 0.0 : spent / budget.amountLimit;

    return BudgetStatus(
      budget: budget,
      spent: spent,
      ratio: ratio,
      isOverThreshold: ratio >= budget.alertThreshold,
      isOverBudget: spent > budget.amountLimit,
    );
  }

  Future<List<BudgetStatus>> getAlerts({
    required int month,
    required int year,
  }) async {
    final budgets = await getForMonth(month: month, year: year);
    final statuses = await Future.wait(budgets.map(checkStatus));
    return statuses.where((s) => s.isOverThreshold).toList();
  }
}
