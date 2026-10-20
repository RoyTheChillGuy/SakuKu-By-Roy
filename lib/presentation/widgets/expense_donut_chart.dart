import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/utils/currency_format.dart';
import '../../core/utils/icon_mapper.dart';
import '../providers/analytics_provider.dart';

class ExpenseDonutChart extends StatefulWidget {
  const ExpenseDonutChart({
    super.key,
    required this.categories,
    required this.total,
  });

  final List<CategorySpend> categories;
  final double total;

  @override
  State<ExpenseDonutChart> createState() => _ExpenseDonutChartState();
}

class _ExpenseDonutChartState extends State<ExpenseDonutChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cats = widget.categories;

    if (cats.isEmpty || widget.total <= 0) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Belum ada pengeluaran di periode ini',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            response == null ||
                            response.touchedSection == null) {
                          _touchedIndex = null;
                          return;
                        }
                        _touchedIndex =
                            response.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  sectionsSpace: 2,
                  centerSpaceRadius: 54,
                  sections: [
                    for (var i = 0; i < cats.length; i++)
                      _section(cats[i], i, widget.total),
                  ],
                ),
                duration: const Duration(milliseconds: 280),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _touchedIndex != null && _touchedIndex! < cats.length
                        ? cats[_touchedIndex!].categoryName
                        : 'Total',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    CurrencyFormat.idrCompact(
                      _touchedIndex != null && _touchedIndex! < cats.length
                          ? cats[_touchedIndex!].amount
                          : widget.total,
                    ),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (var i = 0; i < cats.length; i++)
              _LegendChip(
                spend: cats[i],
                total: widget.total,
                highlighted: _touchedIndex == i,
                onTap: () => setState(() => _touchedIndex = i),
              ),
          ],
        ),
      ],
    );
  }

  PieChartSectionData _section(CategorySpend spend, int index, double total) {
    final selected = index == _touchedIndex;
    final color = IconMapper.colorFromHex(spend.colorHex);
    final pct = total <= 0 ? 0.0 : (spend.amount / total) * 100;

    return PieChartSectionData(
      color: color,
      value: spend.amount,
      title: selected ? '${pct.toStringAsFixed(0)}%' : '',
      radius: selected ? 58 : 48,
      titleStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.spend,
    required this.total,
    required this.highlighted,
    required this.onTap,
  });

  final CategorySpend spend;
  final double total;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = IconMapper.colorFromHex(spend.colorHex);
    final pct = total <= 0 ? 0.0 : (spend.amount / total) * 100;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: highlighted
              ? color.withValues(alpha: 0.18)
              : Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.4),
          border: Border.all(
            color: highlighted ? color : color.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              '${spend.categoryName} ${pct.toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
