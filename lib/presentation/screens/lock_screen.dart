import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pinput/pinput.dart';

import '../../core/security/pin_codec.dart';
import '../../core/theme/glass.dart';
import '../providers/app_lock_provider.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({
    super.key,
    required this.biometricEnabled,
    required this.onUnlocked,
  });

  final bool biometricEnabled;
  final VoidCallback onUnlocked;

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final _pinController = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (widget.biometricEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometric());
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _tryBiometric() async {
    if (_busy) return;
    setState(() => _busy = true);
    final ok = await ref.read(appLockProvider.notifier).unlockWithBiometric();
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      widget.onUnlocked();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Biometrik gagal. Pastikan sidik jari terdaftar di pengaturan HP, '
          'atau gunakan PIN.',
        ),
      ),
    );
  }

  Future<void> _submitPin([String? pin]) async {
    final value = pin ?? _pinController.text;
    if (!PinCodec.isValidFormat(value)) {
      setState(() => _error = 'PIN ${PinCodec.minLength}-${PinCodec.maxLength} digit');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final err =
        await ref.read(appLockProvider.notifier).unlockWithPin(value);
    if (!mounted) return;
    setState(() => _busy = false);
    if (err == null) {
      widget.onUnlocked();
      return;
    }
    setState(() {
      _error = err;
      _pinController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pinTheme = defaultPinTheme(theme);

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.shieldCheck,
                        size: 44,
                        color: theme.colorScheme.primary,
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.08, 1.08),
                            duration: 1400.ms,
                          ),
                      const SizedBox(height: 12),
                      Text(
                        'Keamanan SakuKu',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Masukkan PIN atau gunakan biometrik.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      Pinput(
                        length: PinCodec.maxLength,
                        controller: _pinController,
                        obscureText: true,
                        enabled: !_busy,
                        defaultPinTheme: pinTheme,
                        separatorBuilder: (index) => const SizedBox(width: 6),
                        onCompleted: _submitPin,
                        onChanged: (_) {
                          if (_error != null) setState(() => _error = null);
                        },
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'PIN ${PinCodec.minLength}–${PinCodec.maxLength} digit',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _busy ? null : () => _submitPin(),
                          child: _busy
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Buka aplikasi'),
                        ),
                      ),
                      if (widget.biometricEnabled) ...[
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _busy ? null : _tryBiometric,
                          icon: const Icon(LucideIcons.fingerprint, size: 18),
                          label: const Text('Biometrik / Face ID'),
                        ),
                      ],
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PinTheme defaultPinTheme(ThemeData theme) {
    final border = theme.colorScheme.outline.withValues(alpha: 0.35);
    return PinTheme(
      width: 32,
      height: 46,
      textStyle: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF0F172A)
            : Colors.white.withValues(alpha: 0.9),
      ),
    );
  }
}
