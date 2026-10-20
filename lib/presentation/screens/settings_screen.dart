import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/security/pin_codec.dart';
import '../../core/theme/glass.dart';
import '../providers/app_lock_provider.dart';
import '../providers/settings_actions_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final lockAsync = ref.watch(appLockProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Pengaturan')),
      body: lockAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (lock) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            _SectionTitle(title: 'Keamanan'),
            GlassCard(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Kunci aplikasi (PIN)'),
                    subtitle: Text(
                      lock.hasPin
                          ? 'PIN tersimpan · ${lock.lockEnabled ? "aktif" : "nonaktif"}'
                          : 'Atur PIN 4–8 digit untuk mengaktifkan',
                    ),
                    value: lock.lockEnabled,
                    onChanged: (on) async {
                      if (!lock.hasPin) {
                        if (on) {
                          await _openPinSetup(context, ref, change: false);
                        }
                        return;
                      }
                      if (on) {
                        await ref.read(appLockProvider.notifier).enableLock();
                      } else {
                        final confirm = await _confirm(
                          context,
                          title: 'Nonaktifkan kunci?',
                          message:
                              'PIN dan biometrik akan dihapus dari perangkat.',
                          confirmLabel: 'Nonaktifkan',
                          destructive: true,
                        );
                        if (confirm == true) {
                          await ref
                              .read(appLockProvider.notifier)
                              .disableLock();
                        }
                      }
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(LucideIcons.keyRound),
                    title: Text(lock.hasPin ? 'Ubah PIN' : 'Atur PIN'),
                    trailing: const Icon(LucideIcons.chevronRight, size: 18),
                    onTap: () => _openPinSetup(context, ref, change: lock.hasPin),
                  ),
                  if (lock.biometricAvailable) ...[
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Biometrik'),
                      subtitle: const Text('Sidik jari / Face ID untuk buka kunci'),
                      value: lock.biometricEnabled,
                      onChanged: lock.hasPin && lock.lockEnabled
                          ? (v) async {
                              final err = await ref
                                  .read(appLockProvider.notifier)
                                  .setBiometricEnabled(v);
                              if (err != null && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(err)),
                                );
                              }
                            }
                          : null,
                    ),
                  ] else
                    ListTile(
                      leading: Icon(
                        LucideIcons.fingerprint,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      title: const Text('Biometrik'),
                      subtitle: const Text(
                        'Tidak tersedia di perangkat / browser ini.',
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SectionTitle(title: 'Export data'),
            GlassCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(LucideIcons.fileSpreadsheet),
                    title: const Text('Export CSV'),
                    subtitle: const Text('Semua log transaksi'),
                    trailing: const Icon(LucideIcons.chevronRight, size: 18),
                    onTap: () => _runExport(context, ref, csv: true),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(LucideIcons.fileText),
                    title: const Text('Export PDF'),
                    subtitle: const Text('Laporan tabel transaksi'),
                    trailing: const Icon(LucideIcons.chevronRight, size: 18),
                    onTap: () => _runExport(context, ref, csv: false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SectionTitle(title: 'Data & kalibrasi'),
            GlassCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(LucideIcons.scale),
                    title: const Text('Kalibrasi saldo'),
                    subtitle: const Text(
                      'Hapus semua transaksi & budget, saldo akun jadi Rp 0',
                    ),
                    trailing: const Icon(LucideIcons.chevronRight, size: 18),
                    onTap: () => _recalibrate(context, ref),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      LucideIcons.trash2,
                      color: theme.colorScheme.error,
                    ),
                    title: Text(
                      'Reset semua data',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                    subtitle: const Text(
                      'Hapus transaksi, budget, akun & kategori lalu isi ulang default',
                    ),
                    trailing: const Icon(LucideIcons.chevronRight, size: 18),
                    onTap: () => _resetAll(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _openPinSetup(
    BuildContext context,
    WidgetRef ref, {
    required bool change,
  }) async {
    final oldCtrl = TextEditingController();
    final pinCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        String? localError;
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: Text(change ? 'Ubah PIN' : 'Atur PIN'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (change) ...[
                    TextField(
                      controller: oldCtrl,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'PIN lama'),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: pinCtrl,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: change ? 'PIN baru' : 'PIN',
                      helperText:
                          '${PinCodec.minLength}-${PinCodec.maxLength} digit',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmCtrl,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Konfirmasi PIN'),
                  ),
                  if (localError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      localError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: () async {
                    final notifier = ref.read(appLockProvider.notifier);
                    String? message;
                    if (change) {
                      message = await notifier.changePin(
                        oldCtrl.text,
                        pinCtrl.text,
                        confirmCtrl.text,
                      );
                    } else {
                      message = await notifier.setPin(
                        pinCtrl.text,
                        confirmCtrl.text,
                      );
                    }
                    if (message == null) {
                      if (ctx.mounted) Navigator.pop(ctx);
                    } else {
                      setLocal(() => localError = message);
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
    oldCtrl.dispose();
    pinCtrl.dispose();
    confirmCtrl.dispose();
  }

  static Future<void> _runExport(
    BuildContext context,
    WidgetRef ref, {
    required bool csv,
  }) async {
    try {
      final actions = ref.read(settingsActionsProvider);
      if (csv) {
        await actions.exportCsv();
      } else {
        await actions.exportPdf();
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(csv ? 'CSV siap dibagikan' : 'PDF siap dibagikan'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export gagal: $e')),
        );
      }
    }
  }

  static Future<void> _recalibrate(BuildContext context, WidgetRef ref) async {
    final ok = await _confirm(
      context,
      title: 'Kalibrasi saldo?',
      message:
          'Semua transaksi dan budget akan dihapus. Saldo awal & saldo saat ini setiap akun di-set ke Rp 0. Akun dan kategori tetap ada.',
      confirmLabel: 'Kalibrasi ke nol',
    );
    if (ok != true) return;

    try {
      await ref.read(settingsActionsProvider).recalibrateBalances();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semua saldo direset ke Rp 0')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kalibrasi gagal: $e')),
        );
      }
    }
  }

  static Future<void> _resetAll(BuildContext context, WidgetRef ref) async {
    final ok = await _confirm(
      context,
      title: 'Reset semua data?',
      message:
          'Semua transaksi, budget, akun, dan kategori akan dihapus. Data default akan dibuat ulang. Tindakan ini tidak bisa dibatalkan.',
      confirmLabel: 'Reset',
      destructive: true,
    );
    if (ok != true) return;
    if (!context.mounted) return;

    final typed = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('Ketik RESET'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              hintText: 'RESET',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('Hapus semua'),
            ),
          ],
        );
      },
    );

    if (typed != 'RESET') {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reset dibatalkan')),
        );
      }
      return;
    }

    try {
      await ref.read(settingsActionsProvider).resetAllData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data direset ke default')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reset gagal: $e')),
        );
      }
    }
  }

  static Future<bool?> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    bool destructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: Theme.of(ctx).colorScheme.error,
                  )
                : null,
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
