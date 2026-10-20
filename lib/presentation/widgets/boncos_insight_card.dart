import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/glass.dart';
import '../../core/utils/currency_format.dart';
import '../../core/utils/icon_mapper.dart';
import '../providers/analytics_provider.dart';

class BoncosInsightCard extends StatelessWidget {
  const BoncosInsightCard({super.key, required this.insight});

  final BoncosInsight insight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final change = insight.percentChangeVsPrevious;
    final bloated = insight.isOverspending || change > 0;

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.search,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text('Kenapa Boncos?', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: (bloated ? AppTheme.expense : AppTheme.income)
                    .withValues(alpha: 0.1),
              ),
              child: Row(
                children: [
                  Icon(
                    bloated
                        ? LucideIcons.trendingUp
                        : LucideIcons.trendingDown,
                    size: 18,
                    color: bloated ? AppTheme.expense : AppTheme.income,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      bloated
                          ? 'Pengeluaran membengkak '
                              '${change >= 0 ? '+' : ''}'
                              '${change.toStringAsFixed(0)}% dibanding bulan lalu'
                          : 'Pengeluaran lebih hemat '
                              '${change.toStringAsFixed(0)}% dibanding bulan lalu',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${CurrencyFormat.idr(insight.currentMonthSpend)} vs '
              '${CurrencyFormat.idr(insight.previousMonthSpend)} bulan lalu',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Divider(height: 28),
            Text('Top 3 kategori', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            if (insight.topCategories.isEmpty)
              Text(
                'Belum ada data pengeluaran.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              ...insight.topCategories.map((c) {
                final color = IconMapper.colorFromHex(c.colorHex);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Icon(
                      IconMapper.fromKey(c.icon),
                      size: 16,
                      color: color,
                    ),
                  ),
                  title: Text(c.categoryName),
                  trailing: Text(
                    CurrencyFormat.idr(c.amount),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }),
            if (insight.tagBreakdown.isNotEmpty) ...[
              const Divider(height: 28),
              Text(
                'Tag / merchant impulsif',
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: insight.tagBreakdown.map((t) {
                  return Chip(
                    avatar: const Icon(LucideIcons.tag, size: 14),
                    label: Text(
                      '${t.tag} · ${CurrencyFormat.idrCompact(t.amount)}',
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
    );
  }
}
