import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/export/transaction_export_service.dart';
import '../../data/models/models.dart';
import '../../data/services/database_maintenance.dart';
import 'account_provider.dart';
import 'analytics_provider.dart';
import 'budget_provider.dart';
import 'category_provider.dart';
import 'isar_provider.dart';
import 'repository_providers.dart';
import 'transaction_provider.dart';

final transactionExportServiceProvider = Provider<TransactionExportService>(
  (ref) => TransactionExportService(),
);

final databaseMaintenanceProvider = Provider<DatabaseMaintenance>(
  (ref) {
    ref.watch(databaseProvider);
    return DatabaseMaintenance();
  },
);

/// Export helpers used from the settings screen.
class SettingsActions {
  SettingsActions(this.ref);

  final Ref ref;

  Future<List<Transaction>> _allTransactions() {
    return ref.read(transactionRepositoryProvider).getAll();
  }

  Future<Map<int, Account>> _accountsMap() async {
    final list = await ref.read(accountListProvider.future);
    return {for (final a in list) a.id: a};
  }

  Future<Map<int, Category>> _categoriesMap() async {
    final list = await ref.read(categoryListProvider.future);
    return {for (final c in list) c.id: c};
  }

  Future<void> exportCsv() async {
    final txs = await _allTransactions();
    final accounts = await _accountsMap();
    final categories = await _categoriesMap();
    await ref.read(transactionExportServiceProvider).shareCsv(
          transactions: txs,
          accountsById: accounts,
          categoriesById: categories,
        );
  }

  Future<void> exportPdf() async {
    final txs = await _allTransactions();
    final accounts = await _accountsMap();
    final categories = await _categoriesMap();
    await ref.read(transactionExportServiceProvider).sharePdf(
          transactions: txs,
          accountsById: accounts,
          categoriesById: categories,
        );
  }

  Future<void> recalibrateBalances() async {
    await ref.read(databaseMaintenanceProvider).recalibrateBalances();
    ref.read(transactionFilterProvider.notifier).resetToCurrentMonth();
    _invalidateAll();
  }

  Future<void> resetAllData() async {
    await ref.read(databaseMaintenanceProvider).wipeAllAndReseed();
    _invalidateAll();
    ref.read(transactionFilterProvider.notifier).resetToCurrentMonth();
  }

  void _invalidateAll() {
    ref.invalidate(accountListProvider);
    ref.invalidate(totalNetWorthProvider);
    ref.invalidate(categoryListProvider);
    ref.invalidate(transactionListProvider);
    ref.invalidate(recentTransactionsProvider);
    ref.invalidate(budgetStatusesProvider);
    ref.invalidate(monthlyCashFlowProvider);
    ref.invalidate(boncosInspectorProvider);
    ref.invalidate(expenseBreakdownProvider);
    ref.invalidate(criticalBudgetAlertsProvider);
  }
}

final settingsActionsProvider = Provider<SettingsActions>(
  (ref) => SettingsActions(ref),
);
