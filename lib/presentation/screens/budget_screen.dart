import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/glass.dart';
import '../../core/utils/async_value_x.dart';
import '../../core/utils/currency_format.dart';
import '../../core/utils/icon_mapper.dart';
import '../../data/models/models.dart';
import '../../data/repositories/budget_repository.dart';
import '../providers/providers.dart';
import '../widgets/budget_alert_banner.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/month_period_selector.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statuses = ref.watch(budgetStatusesProvider);
    final categories = ref.watch(categoryListProvider);
    final period = ref.watch(budgetPeriodProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () => ref.read(budgetStatusesProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          children: [
            const MonthPeriodSelector(),
            const SizedBox(height: 8),
            const BudgetAlertBanner(),
            statuses.when(
              data: (list) {
                if (list.isEmpty) {
                  return EmptyState(
                    message:
                        'Belum ada budget untuk ${period.month}/${period.year}. '
                        'Set limit pengeluaran per kategori.',
                    actionLabel: 'Set budget',
                    onAction: () => _openBudgetDialog(context, ref),
                  );
                }

                final cats = categories.dataOrNull ?? const <Category>[];
                return Column(
                  children: list.map((status) {
                    return _BudgetProgressCard(
                      status: status,
                      categoryName: _categoryName(status, cats),
                      categoryIcon: _categoryIcon(status, cats),
                      categoryColor: _categoryColor(status, cats),
                      onEdit: () => _openBudgetDialog(
                        context,
                        ref,
                        existing: status.budget,
                      ),
                      onDelete: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Hapus budget?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Batal'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Hapus'),
                              ),
                            ],
                          ),
                        );
                        if (ok == true) {
                          await ref
                              .read(budgetStatusesProvider.notifier)
                              .remove(status.budget.id);
                        }
                      },
                    );
                  }).toList(),
                );
              },
              loading: () => const Column(
                children: [
                  LoadingSkeleton(height: 110, borderRadius: 16),
                  SizedBox(height: 10),
                  LoadingSkeleton(height: 110, borderRadius: 16),
                ],
              ),
              error: (e, _) => Text('$e'),
            ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: () => _openBudgetDialog(context, ref),
              icon: const Icon(LucideIcons.plus),
              label: const Text('Tambah / edit budget'),
            ),
            const SizedBox(height: 8),
            Text(
              'Hijau < 75% · Kuning 75–90% · Merah > 90% / over budget',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryName(BudgetStatus status, List<Category> cats) {
    if (status.budget.categoryId == null) return 'Budget keseluruhan';
    return cats
            .where((c) => c.id == status.budget.categoryId)
            .map((c) => c.name)
            .firstOrNull ??
        'Kategori #${status.budget.categoryId}';
  }

  String _categoryIcon(BudgetStatus status, List<Category> cats) {
    if (status.budget.categoryId == null) return 'wallet';
    return cats
            .where((c) => c.id == status.budget.categoryId)
            .map((c) => c.icon)
            .firstOrNull ??
        'circle';
  }

  Color _categoryColor(BudgetStatus status, List<Category> cats) {
    if (status.budget.categoryId == null) {
      return AppTheme.transfer;
    }
    final hex = cats
        .where((c) => c.id == status.budget.categoryId)
        .map((c) => c.colorHex)
        .firstOrNull;
    return IconMapper.colorFromHex(hex);
  }
}

class _BudgetProgressCard extends StatelessWidget {
  const _BudgetProgressCard({
    required this.status,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.onEdit,
    required this.onDelete,
  });

  final BudgetStatus status;
  final String categoryName;
  final String categoryIcon;
  final Color categoryColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = status.ratio;
    final barColor = AppTheme.budgetStatusColor(ratio);
    final remaining = status.remaining;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: categoryColor.withValues(alpha: 0.15),
                  child: Icon(
                    IconMapper.fromKey(categoryIcon),
                    size: 18,
                    color: categoryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${CurrencyFormat.idr(status.spent)} / '
                        '${CurrencyFormat.idr(status.budget.amountLimit)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(ratio * 100).clamp(0, 999).toStringAsFixed(0)}%',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: barColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Hapus')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ratio.clamp(0.0, 1.0),
                minHeight: 10,
                color: barColor,
                backgroundColor: barColor.withValues(alpha: 0.15),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              remaining >= 0
                  ? 'Tersisa ${CurrencyFormat.idr(remaining)} dari '
                      '${CurrencyFormat.idr(status.budget.amountLimit)}'
                  : 'Over ${CurrencyFormat.idr(remaining.abs())} dari limit '
                      '${CurrencyFormat.idr(status.budget.amountLimit)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: remaining >= 0
                    ? theme.colorScheme.onSurfaceVariant
                    : AppTheme.overBudget,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _openBudgetDialog(
  BuildContext context,
  WidgetRef ref, {
  Budget? existing,
}) async {
  final period = ref.read(budgetPeriodProvider);
  final categories = await ref.read(categoriesByTypeProvider(CategoryType.expense).future);
  final statuses = ref.read(budgetStatusesProvider).dataOrNull ?? [];

  int? selectedCategoryId = existing?.categoryId;
  final amountCtrl = TextEditingController(
    text: existing == null
        ? ''
        : CurrencyFormat.formatInputDigits(
            existing.amountLimit.round().toString(),
          ),
  );

  // Categories that already have a budget this month (exclude current edit).
  final taken = statuses
      .map((s) => s.budget.categoryId)
      .where((id) => id != existing?.categoryId)
      .toSet();

  final availableIds = <int?>[
    null, // overall budget
    ...categories.where((c) => !taken.contains(c.id)).map((c) => c.id),
  ];

  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setLocal) {
          return AlertDialog(
            title: Text(existing == null ? 'Set budget' : 'Edit budget'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int?>(
                    dropdownColor: Glass.modalSurface(context),
                    key: ValueKey('budget-cat-$selectedCategoryId'),
                    initialValue: selectedCategoryId,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    items: [
                      for (final id in availableIds)
                        DropdownMenuItem(
                          value: id,
                          child: Text(
                            id == null
                                ? 'Budget keseluruhan'
                                : categories
                                      .firstWhere((c) => c.id == id)
                                      .name,
                          ),
                        ),
                    ],
                    onChanged: existing != null
                        ? null
                        : (v) => setLocal(() => selectedCategoryId = v),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Limit bulanan',
                      prefixText: 'Rp ',
                    ),
                    onChanged: (v) {
                      final formatted = CurrencyFormat.formatInputDigits(v);
                      if (formatted != v) {
                        amountCtrl.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(
                            offset: formatted.length,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () async {
                  final amount = CurrencyFormat.parseInput(amountCtrl.text);
                  if (amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Masukkan limit valid')),
                    );
                    return;
                  }

                  final budget = existing ?? Budget();
                  budget
                    ..categoryId = selectedCategoryId
                    ..amountLimit = amount
                    ..month = period.month
                    ..year = period.year
                    ..alertThreshold = 0.75;

                  final notifier = ref.read(budgetStatusesProvider.notifier);
                  if (existing != null) {
                    await notifier.updateBudget(budget);
                  } else {
                    await notifier.add(budget);
                  }
                  ref.invalidate(criticalBudgetAlertsProvider);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      );
    },
  );

  amountCtrl.dispose();
}
