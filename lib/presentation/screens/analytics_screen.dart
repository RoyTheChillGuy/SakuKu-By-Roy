import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/animation/entrance_animations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/glass.dart';
import '../../core/utils/currency_format.dart';
import '../providers/providers.dart';
import '../widgets/boncos_insight_card.dart';
import '../widgets/budget_alert_banner.dart';
import '../widgets/empty_state.dart';
import '../widgets/expense_donut_chart.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/month_period_selector.dart';
import '../widgets/summary_card.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({
    super.key,
    this.onOpenBudgets,
  });

  final VoidCallback? onOpenBudgets;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cashFlow = ref.watch(monthlyCashFlowProvider);
    final boncos = ref.watch(boncosInspectorProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(monthlyCashFlowProvider);
          ref.invalidate(boncosInspectorProvider);
          ref.invalidate(budgetStatusesProvider);
          ref.invalidate(criticalBudgetAlertsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          children: [
            const MonthPeriodSelector().entranceCard(0),
            const SizedBox(height: 8),
            BudgetAlertBanner(onTap: onOpenBudgets).entranceCard(1),
            cashFlow.when(
              data: (flow) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GlassCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cash flow',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: SummaryCard(
                                label: 'Pemasukan',
                                amount: flow.income,
                                color: AppTheme.income,
                                icon: LucideIcons.arrowDownLeft,
                              ),
                            ),
                            const SizedBox(width: 10),
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
                        const SizedBox(height: 12),
                        _NetRow(flow: flow),
                      ],
                    ),
                  ).entranceCard(2),
                ],
              ),
              loading: () =>
                  const LoadingSkeleton(height: 200, borderRadius: 20),
              error: (e, _) => Text('$e'),
            ),
            const SizedBox(height: 16),
            Text('Distribusi pengeluaran', style: theme.textTheme.titleMedium)
                .entranceCard(3),
            const SizedBox(height: 8),
            boncos.when(
              data: (insight) => GlassCard(
                padding: const EdgeInsets.all(16),
                child: ExpenseDonutChart(
                  categories: insight.allCategories,
                  total: insight.currentMonthSpend,
                ),
              ).entranceCard(4),
              loading: () =>
                  const LoadingSkeleton(height: 280, borderRadius: 20),
              error: (e, _) => Text('$e'),
            ),
            const SizedBox(height: 16),
            boncos.when(
              data: (insight) {
                if (insight.currentMonthSpend <= 0 &&
                    insight.topCategories.isEmpty) {
                  return const EmptyState(
                    message: 'Belum ada transaksi bulan ini untuk dianalisis.',
                  ).entranceCard(5);
                }
                return BoncosInsightCard(insight: insight).entranceCard(5);
              },
              loading: () =>
                  const LoadingSkeleton(height: 220, borderRadius: 20),
              error: (e, _) => Text('$e'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NetRow extends StatelessWidget {
  const _NetRow({required this.flow});

  final MonthlyCashFlow flow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final positive = flow.net >= 0;

    return GlassCard(
      borderRadius: BorderRadius.circular(14),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Net',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormat.idr(flow.net),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: positive ? AppTheme.income : AppTheme.expense,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Savings rate',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(flow.savingsRate * 100).toStringAsFixed(0)}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

