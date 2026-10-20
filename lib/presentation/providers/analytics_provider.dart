import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/models.dart';
import '../../data/repositories/budget_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import 'budget_provider.dart';
import 'repository_providers.dart';

part 'analytics_provider.g.dart';

/// Income / expense / net snapshot for a month.
class MonthlyCashFlow {
  const MonthlyCashFlow({
    required this.income,
    required this.expenses,
    required this.net,
    required this.month,
    required this.year,
  });

  final double income;
  final double expenses;
  final double net;
  final int month;
  final int year;

  /// (income - expenses) / income; 0 when income is zero.
  double get savingsRate {
    if (income <= 0) return 0;
    return net / income;
  }
}

/// Spending total for one category.
class CategorySpend {
  const CategorySpend({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.colorHex,
    required this.icon,
  });

  final int categoryId;
  final String categoryName;
  final double amount;
  final String colorHex;
  final String icon;
}

/// Tag / merchant style spend aggregate for impulsive-spend hints.
class TagSpend {
  const TagSpend({required this.tag, required this.amount});

  final String tag;
  final double amount;
}

/// "Kenapa Boncos?" inspector payload.
class BoncosInsight {
  const BoncosInsight({
    required this.topCategories,
    required this.currentMonthSpend,
    required this.previousMonthSpend,
    required this.percentChangeVsPrevious,
    required this.tagBreakdown,
    required this.isOverspending,
    required this.allCategories,
  });

  final List<CategorySpend> topCategories;
  final List<CategorySpend> allCategories;
  final double currentMonthSpend;
  final double previousMonthSpend;

  /// Positive = spent more than last month (worse).
  final double percentChangeVsPrevious;
  final List<TagSpend> tagBreakdown;
  final bool isOverspending;
}

DateTime _startOfMonth(int year, int month) => DateTime(year, month, 1);

DateTime _endOfMonth(int year, int month) =>
    DateTime(year, month + 1, 0, 23, 59, 59);

({int month, int year}) _shiftMonth(int month, int year, int delta) {
  final d = DateTime(year, month + delta, 1);
  return (month: d.month, year: d.year);
}

/// Income, expenses, net, and savings rate for the selected [budgetPeriodProvider].
@riverpod
Future<MonthlyCashFlow> monthlyCashFlow(Ref ref) async {
  final period = ref.watch(budgetPeriodProvider);
  final repo = ref.watch(transactionRepositoryProvider);
  final start = _startOfMonth(period.year, period.month);
  final end = _endOfMonth(period.year, period.month);

  final income = await repo.sumIncome(start: start, end: end);
  final expenses = await repo.sumExpenses(start: start, end: end);

  return MonthlyCashFlow(
    income: income,
    expenses: expenses,
    net: income - expenses,
    month: period.month,
    year: period.year,
  );
}

/// Full category expense breakdown for the selected period (charts).
@riverpod
Future<List<CategorySpend>> expenseBreakdown(Ref ref) async {
  final insight = await ref.watch(boncosInspectorProvider.future);
  return insight.allCategories;
}

/// Top spend categories, MoM comparison, and tag breakdown for selected period.
@riverpod
Future<BoncosInsight> boncosInspector(Ref ref) async {
  final period = ref.watch(budgetPeriodProvider);
  final txRepo = ref.watch(transactionRepositoryProvider);
  final catRepo = ref.watch(categoryRepositoryProvider);

  final currentStart = _startOfMonth(period.year, period.month);
  final currentEnd = _endOfMonth(period.year, period.month);
  final prev = _shiftMonth(period.month, period.year, -1);
  final prevStart = _startOfMonth(prev.year, prev.month);
  final prevEnd = _endOfMonth(prev.year, prev.month);

  final currentExpenses = await txRepo.getFiltered(
    TransactionFilter(
      start: currentStart,
      end: currentEnd,
      type: TransactionType.expense,
    ),
  );
  final previousExpenses = await txRepo.getFiltered(
    TransactionFilter(
      start: prevStart,
      end: prevEnd,
      type: TransactionType.expense,
    ),
  );

  final currentTotal =
      currentExpenses.fold<double>(0, (s, t) => s + t.amount);
  final previousTotal =
      previousExpenses.fold<double>(0, (s, t) => s + t.amount);

  final byCategory = <int, double>{};
  final byTag = <String, double>{};

  for (final tx in currentExpenses) {
    if (tx.categoryId != null) {
      byCategory.update(
        tx.categoryId!,
        (v) => v + tx.amount,
        ifAbsent: () => tx.amount,
      );
    }
    for (final tag in tx.tags) {
      final key = tag.trim();
      if (key.isEmpty) continue;
      byTag.update(key, (v) => v + tx.amount, ifAbsent: () => tx.amount);
    }
  }

  final sortedCats = byCategory.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  Future<CategorySpend> toSpend(MapEntry<int, double> entry) async {
    final category = await catRepo.getById(entry.key);
    return CategorySpend(
      categoryId: entry.key,
      categoryName: category?.name ?? 'Unknown',
      amount: entry.value,
      colorHex: category?.colorHex ?? '#94A3B8',
      icon: category?.icon ?? 'circle',
    );
  }

  final allCategories = <CategorySpend>[];
  for (final entry in sortedCats) {
    allCategories.add(await toSpend(entry));
  }

  final tags = byTag.entries
      .map((e) => TagSpend(tag: e.key, amount: e.value))
      .toList()
    ..sort((a, b) => b.amount.compareTo(a.amount));

  final percentChange = previousTotal <= 0
      ? (currentTotal > 0 ? 100.0 : 0.0)
      : ((currentTotal - previousTotal) / previousTotal) * 100;

  return BoncosInsight(
    topCategories: allCategories.take(3).toList(),
    allCategories: allCategories,
    currentMonthSpend: currentTotal,
    previousMonthSpend: previousTotal,
    percentChangeVsPrevious: percentChange,
    tagBreakdown: tags.take(8).toList(),
    isOverspending: currentTotal > previousTotal && previousTotal > 0,
  );
}

/// Budgets at ≥90% or over limit for banner alerts.
@riverpod
Future<List<BudgetStatus>> criticalBudgetAlerts(Ref ref) async {
  final statuses = await ref.watch(budgetStatusesProvider.future);
  return statuses.where((s) => s.ratio >= 0.90 || s.isOverBudget).toList();
}
