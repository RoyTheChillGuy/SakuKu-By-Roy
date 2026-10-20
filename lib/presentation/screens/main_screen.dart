import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:badges/badges.dart' as badges;

import '../../core/services/scan_receipt_flow.dart';
import '../../core/services/widget_service.dart';
import '../../core/theme/glass.dart';
import '../../core/theme/page_transitions.dart';
import '../providers/providers.dart';
import 'accounts_screen.dart';
import 'add_transaction_bottom_sheet.dart';
import 'analytics_hub_screen.dart';
import 'dashboard_screen.dart';
import 'transaction_history_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _index = 0;
  StreamSubscription<void>? _scanLaunchSub;
  bool _scanFlowRunning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _launchScanReceiptIfPending();
    });
    _scanLaunchSub =
        WidgetLaunchService.instance.scanReceiptTriggers.listen((_) {
      _launchScanReceiptIfPending();
    });
  }

  @override
  void dispose() {
    _scanLaunchSub?.cancel();
    super.dispose();
  }

  Future<void> _launchScanReceiptIfPending() async {
    if (_scanFlowRunning || !mounted) return;
    if (!WidgetLaunchService.instance.consumePendingScanReceipt()) return;
    _scanFlowRunning = true;
    setState(() => _index = 0);
    try {
      await runScanReceiptFlow(context);
    } finally {
      _scanFlowRunning = false;
    }
  }

  void _goTo(int index) {
    if (_index == index) return;
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final alertCount = ref
            .watch(criticalBudgetAlertsProvider)
            .asData
            ?.value
            .length ??
        0;

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: IndexedStack(
          index: _index,
          sizing: StackFit.expand,
          children: [
            KeepAlivePage(
              child: DashboardScreen(
                onViewAllTransactions: () => _goTo(1),
                onOpenBudgets: () => _goTo(2),
              ),
            ),
            const KeepAlivePage(child: TransactionHistoryScreen()),
            const KeepAlivePage(child: AnalyticsHubScreen()),
            const KeepAlivePage(child: AccountsScreen()),
          ],
        ),
        floatingActionButton: _GlassFab(
          onPressed: () => showAddTransactionSheet(context),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: GlassBar(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              _NavItem(
                icon: LucideIcons.layoutDashboard,
                label: 'Beranda',
                selected: _index == 0,
                onTap: () => _goTo(0),
              ),
              _NavItem(
                icon: LucideIcons.receipt,
                label: 'Transaksi',
                selected: _index == 1,
                onTap: () => _goTo(1),
              ),
              const SizedBox(width: 56),
              _NavItem(
                icon: LucideIcons.pieChart,
                label: 'Analitik',
                selected: _index == 2,
                onTap: () => _goTo(2),
                badgeCount: alertCount,
              ),
              _NavItem(
                icon: LucideIcons.wallet,
                label: 'Akun',
                selected: _index == 3,
                onTap: () => _goTo(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassFab extends StatefulWidget {
  const _GlassFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_GlassFab> createState() => _GlassFabState();
}

class _GlassFabState extends State<_GlassFab>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulse;

  @override
  void initState() {
    super.initState();
    _startPulse();
  }

  void _startPulse() {
    _pulse?.dispose();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final pulse = _pulse;
    if (pulse == null) {
      return _fabBody(primary, widget.onPressed, null);
    }

    return ScaleTransition(
      scale: Tween<double>(begin: 1, end: 1.05).animate(
        CurvedAnimation(parent: pulse, curve: Curves.easeInOut),
      ),
      child: _fabBody(primary, widget.onPressed, null),
    );
  }

  Widget _fabBody(Color primary, VoidCallback onPressed, Widget? child) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: primary.withValues(alpha: 0.88),
          shape: const CircleBorder(
            side: BorderSide(color: Colors.white54, width: 1.2),
          ),
          elevation: 8,
          shadowColor: primary.withValues(alpha: 0.45),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: child ??
                const SizedBox(
                  width: 58,
                  height: 58,
                  child: Icon(LucideIcons.plus, color: Colors.white),
                ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = selected
        ? theme.colorScheme.primary
        : (isDark
            ? Colors.white.withValues(alpha: 0.55)
            : theme.colorScheme.onSurfaceVariant);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: AppMotion.quick,
          curve: AppMotion.curve,
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: selected
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.4),
                  ),
                )
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: selected ? 1.12 : 1.0,
                duration: AppMotion.quick,
                curve: AppMotion.curve,
                child: badges.Badge(
                  showBadge: badgeCount > 0,
                  badgeContent: Text(
                    badgeCount > 9 ? '9+' : '$badgeCount',
                    style: const TextStyle(fontSize: 9, color: Colors.white),
                  ),
                  badgeStyle: badges.BadgeStyle(
                    badgeColor: theme.colorScheme.error,
                    padding: const EdgeInsets.all(4),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: AppMotion.quick,
                curve: AppMotion.curve,
                style: (theme.textTheme.labelSmall ?? const TextStyle()).copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
