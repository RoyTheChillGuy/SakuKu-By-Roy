import '../../models/models.dart';
import '../../services/web/memory_store.dart';
import '../budget_status.dart';
import 'transaction_repository.dart';

export '../budget_status.dart';

class BudgetRepository {
  BudgetRepository({
    Object? isar,
    TransactionRepository? transactionRepository,
  }) : _transactions = transactionRepository ?? TransactionRepository();

  final TransactionRepository _transactions;
  MemoryStore get _store => MemoryStore.instance;

  Future<List<Budget>> getAll() async {
    final list = List<Budget>.from(_store.budgets);
    list.sort((a, b) {
      final yearCmp = b.year.compareTo(a.year);
      if (yearCmp != 0) return yearCmp;
      return b.month.compareTo(a.month);
    });
    return list;
  }

  Future<List<Budget>> getForMonth({
    required int month,
    required int year,
  }) async {
    return _store.budgets
        .where((b) => b.month == month && b.year == year)
        .toList();
  }

  Future<Budget?> getById(int id) async {
    for (final b in _store.budgets) {
      if (b.id == id) return b;
    }
    return null;
  }

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

  Future<int> create(Budget budget) async {
    budget.id = _store.nextBudgetId();
    budget.createdAt = DateTime.now();
    _store.budgets.add(budget);
    return budget.id;
  }

  Future<int> update(Budget budget) async {
    final index = _store.budgets.indexWhere((b) => b.id == budget.id);
    if (index >= 0) {
      _store.budgets[index] = budget;
    }
    return budget.id;
  }

  Future<bool> delete(int id) async {
    final before = _store.budgets.length;
    _store.budgets.removeWhere((b) => b.id == id);
    return _store.budgets.length < before;
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
