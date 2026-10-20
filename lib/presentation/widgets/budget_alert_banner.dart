import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/glass.dart';
import '../../core/utils/async_value_x.dart';
import '../../core/utils/currency_format.dart';
import '../providers/providers.dart';

/// Banner shown when any budget is ≥90% used or over budget.
class BudgetAlertBanner extends ConsumerWidget {
  const BudgetAlertBanner({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(criticalBudgetAlertsProvider);
    final categories = ref.watch(categoryListProvider).dataOrNull ?? [];

    return alerts.when(
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();
        final first = list.first;
        final catName = first.budget.categoryId == null
            ? 'Budget keseluruhan'
            : categories
                    .where((c) => c.id == first.budget.categoryId)
                    .map((c) => c.name)
                    .firstOrNull ??
                'Kategori';
        final over = first.isOverBudget;
        final accent = over ? AppTheme.overBudget : AppTheme.warning;
        final message = over
            ? '$catName sudah over budget '
                '(${CurrencyFormat.idr(first.spent)} / '
                '${CurrencyFormat.idr(first.budget.amountLimit)})'
            : '$catName hampir habis '
                '(${(first.ratio * 100).toStringAsFixed(0)}% terpakai)'
                '${list.length > 1 ? ' · +${list.length - 1} lainnya' : ''}';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            tint: accent.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(
                  over ? LucideIcons.alertTriangle : LucideIcons.bell,
                  size: 20,
                  color: accent,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                if (onTap != null)
                  Icon(
                    LucideIcons.chevronRight,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
