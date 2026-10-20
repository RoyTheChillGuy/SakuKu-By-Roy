import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/glass.dart';
import '../../core/utils/date_labels.dart';
import '../providers/providers.dart';

class MonthPeriodSelector extends ConsumerWidget {
  const MonthPeriodSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final period = ref.watch(budgetPeriodProvider);
    final date = DateTime(period.year, period.month);

    return GlassCard(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Bulan sebelumnya',
            onPressed: () {
              final prev = DateTime(period.year, period.month - 1);
              ref.read(budgetPeriodProvider.notifier).setPeriod(
                    month: prev.month,
                    year: prev.year,
                  );
            },
            icon: const Icon(LucideIcons.chevronLeft),
          ),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  helpText: 'Pilih bulan',
                );
                if (picked != null) {
                  ref.read(budgetPeriodProvider.notifier).setPeriod(
                        month: picked.month,
                        year: picked.year,
                      );
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  DateLabels.monthYear(date),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Bulan berikutnya',
            onPressed: () {
              final next = DateTime(period.year, period.month + 1);
              final now = DateTime.now();
              if (next.year > now.year ||
                  (next.year == now.year && next.month > now.month + 1)) {
                return;
              }
              ref.read(budgetPeriodProvider.notifier).setPeriod(
                    month: next.month,
                    year: next.year,
                  );
            },
            icon: const Icon(LucideIcons.chevronRight),
          ),
        ],
      ),
    );
  }
}
