import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/animation/entrance_animations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/glass.dart';
import '../../core/utils/async_value_x.dart';
import '../../core/utils/currency_format.dart';
import '../../core/utils/quick_receipt_capture.dart';
import '../../data/models/models.dart';
import '../providers/providers.dart';
import '../widgets/account_chip_card.dart';
import '../widgets/budget_alert_banner.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_bottom_sheet.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({
    super.key,
    this.onViewAllTransactions,
    this.onOpenBudgets,
  });

  final VoidCallback? onViewAllTransactions;
  final VoidCallback? onOpenBudgets;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final netWorth = ref.watch(totalNetWorthProvider);
    final cashFlow = ref.watch(monthlyCashFlowProvider);
    final accounts = ref.watch(accountListProvider);
    final recent = ref.watch(recentTransactionsProvider(limit: 5));
    final categories = ref.watch(categoryListProvider);

    final isLoading = netWorth.isLoading ||
        cashFlow.isLoading ||
        accounts.isLoading ||
        recent.isLoading;

    if (isLoading && !netWorth.hasValue) {
      return const DashboardSkeleton();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(totalNetWorthProvider);
        ref.invalidate(monthlyCashFlowProvider);
        ref.invalidate(accountListProvider);
        ref.invalidate(recentTransactionsProvider);
        ref.invalidate(categoryListProvider);
        ref.invalidate(criticalBudgetAlertsProvider);
        ref.invalidate(budgetStatusesProvider);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            actions: [
              IconButton(
                tooltip: 'Foto struk — catat cepat',
                icon: const Icon(LucideIcons.camera),
                onPressed: () => captureReceiptAndOpenTransactionForm(context),
              ),
              const SizedBox(width: 4),
            ],
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SakuKu',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Ringkasan keuanganmu',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: SliverToBoxAdapter(
              child: BudgetAlertBanner(onTap: onOpenBudgets).entranceCard(0),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: SliverToBoxAdapter(
              child: GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Saldo',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    netWorth.when(
                      data: (value) => Text(
                        CurrencyFormat.idr(value),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      loading: () =>
                          const LoadingSkeleton(height: 32, width: 180),
                      error: (e, _) => Text('$e'),
                    ),
                  ],
                ),
              ).entranceCard(1),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            sliver: SliverToBoxAdapter(
              child: cashFlow.when(
                data: (flow) => Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        label: 'Pemasukan',
                        amount: flow.income,
                        color: AppTheme.income,
                        icon: LucideIcons.arrowDownLeft,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SummaryCard(
                        label: 'Pengeluaran',
                        amount: flow.expenses,
                        color: AppTheme.expense,
                        icon: LucideIcons.arrowUpRight,
                      ),
                    ),
                  ],
                ),
                loading: () => const Row(
                  children: [
                    Expanded(child: LoadingSkeleton(height: 88)),
                    SizedBox(width: 12),
                    Expanded(child: LoadingSkeleton(height: 88)),
                  ],
                ),
                error: (e, _) => Text('Cash flow error: $e'),
              ).entranceCard(2),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Text('Dompet', style: theme.textTheme.titleMedium)
                  .entranceCard(3),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 128,
              child: accounts.when(
                data: (list) {
                  if (list.isEmpty) {
                    return const EmptyState(
                      message: 'Belum ada dompet. Seed data akan muncul di sini.',
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) =>
                        AccountChipCard(account: list[index]),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: LoadingSkeleton(height: 128, borderRadius: 20),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('$e'),
                ),
              ),
            ).entranceCard(4),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Transaksi Terbaru',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: onViewAllTransactions,
                    child: const Text('Lihat semua'),
                  ),
                ],
              ).entranceCard(5),
            ),
          ),
          recent.when(
            data: (txs) {
              if (txs.isEmpty) {
                return SliverToBoxAdapter(
                  child: EmptyState(
                    message: 'Belum ada transaksi bulan ini',
                    actionLabel: 'Tambah transaksi',
                    onAction: () => showAddTransactionSheet(context),
                  ),
                );
              }
              final cats = categories.dataOrNull ?? const <Category>[];
              final accs = accounts.dataOrNull ?? const <Account>[];
              return SliverList.builder(
                itemCount: txs.length,
                itemBuilder: (context, index) {
                  final tx = txs[index];
                  final cat = cats.cast<Category?>().firstWhere(
                        (c) => c?.id == tx.categoryId,
                        orElse: () => null,
                      );
                  final acc = accs.cast<Account?>().firstWhere(
                        (a) => a?.id == tx.accountId,
                        orElse: () => null,
                      );
                  return TransactionTile(
                    transaction: tx,
                    category: cat,
                    accountName: acc?.name,
                    onTap: () =>
                        showAddTransactionSheet(context, existing: tx),
                  );
                },
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    LoadingSkeleton(height: 64),
                    SizedBox(height: 10),
                    LoadingSkeleton(height: 64),
                  ],
                ),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(child: Text('$e')),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      ),
    );
  }
}
