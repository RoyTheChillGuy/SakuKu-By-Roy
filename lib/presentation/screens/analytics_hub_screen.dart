import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/glass.dart';
import '../../core/theme/page_transitions.dart';
import 'analytics_screen.dart';
import 'budget_screen.dart';

/// Combined Analitik + Budget tab with a segmented switcher.
class AnalyticsHubScreen extends StatefulWidget {
  const AnalyticsHubScreen({super.key});

  @override
  State<AnalyticsHubScreen> createState() => _AnalyticsHubScreenState();
}

class _AnalyticsHubScreenState extends State<AnalyticsHubScreen> {
  int _section = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: GlassCard(
              borderRadius: BorderRadius.circular(16),
              padding: const EdgeInsets.all(6),
              child: SegmentedButton<int>(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.18);
                    }
                    return Colors.transparent;
                  }),
                  side: const WidgetStatePropertyAll(BorderSide.none),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                segments: const [
                  ButtonSegment(
                    value: 0,
                    label: Text('Analitik'),
                    icon: Icon(LucideIcons.pieChart, size: 16),
                  ),
                  ButtonSegment(
                    value: 1,
                    label: Text('Budget'),
                    icon: Icon(LucideIcons.gauge, size: 16),
                  ),
                ],
                selected: {_section},
                onSelectionChanged: (v) => setState(() => _section = v.first),
              ),
            ),
          ),
        ),
        Expanded(
          child: FadeSlideSwitcher(
            slideOffset: _section == 0 ? -0.04 : 0.04,
            child: KeyedSubtree(
              key: ValueKey(_section),
              child: _section == 0
                  ? AnalyticsScreen(
                      onOpenBudgets: () => setState(() => _section = 1),
                    )
                  : const BudgetScreen(),
            ),
          ),
        ),
      ],
    );
  }
}
