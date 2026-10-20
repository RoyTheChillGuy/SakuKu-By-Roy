import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/glass.dart';
import '../../core/utils/async_value_x.dart';
import '../../core/utils/currency_format.dart';
import '../../core/utils/icon_mapper.dart';
import '../providers/providers.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_skeleton.dart';
import 'settings_screen.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accounts = ref.watch(accountListProvider);
    final netWorth = ref.watch(totalNetWorthProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Akun & Dompet'),
        actions: [
          IconButton(
            tooltip: 'Pengaturan',
            icon: const Icon(LucideIcons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: accounts.when(
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(message: 'Belum ada akun tersimpan.');
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total kekayaan bersih',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      CurrencyFormat.idr(netWorth.dataOrNull ?? 0),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...list.map((account) {
                final color = IconMapper.colorFromHex(account.colorHex);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GlassCard(
                    tint: color.withValues(alpha: 0.1),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: color.withValues(alpha: 0.18),
                        child: Icon(
                          IconMapper.fromKey(account.icon),
                          color: color,
                          size: 20,
                        ),
                      ),
                      title: Text(account.name),
                      subtitle: Text(_typeLabel(account.type.name)),
                      trailing: Text(
                        CurrencyFormat.idr(account.currentBalance),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                },
                icon: const Icon(LucideIcons.settings, size: 18),
                label: const Text('Pengaturan & keamanan'),
              ),
            ],
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              LoadingSkeleton(height: 100, borderRadius: 20),
              SizedBox(height: 12),
              LoadingSkeleton(height: 72),
              SizedBox(height: 10),
              LoadingSkeleton(height: 72),
            ],
          ),
        ),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'cash':
        return 'Tunai';
      case 'bank':
        return 'Rekening bank';
      case 'eWallet':
        return 'E-Wallet';
      case 'creditCard':
        return 'Kartu kredit';
      case 'savings':
        return 'Tabungan';
      default:
        return type;
    }
  }
}

/// Lightweight settings stub linked from accounts tab overflow if needed.
class SettingsHint extends StatelessWidget {
  const SettingsHint({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      leading: Icon(LucideIcons.settings),
      title: Text('Pengaturan'),
      subtitle: Text('Segera hadir'),
    );
  }
}
