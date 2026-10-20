import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_lock_provider.dart';
import '../screens/lock_screen.dart';

/// Shows [LockScreen] when app lock is enabled and session is locked.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(appLockProvider.notifier).lockFromBackground();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lockAsync = ref.watch(appLockProvider);

    return lockAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (lock) {
        if (lock.lockEnabled && !lock.isUnlocked) {
          return LockScreen(
            biometricEnabled: lock.biometricEnabled,
            onUnlocked: () {},
          );
        }
        return widget.child;
      },
    );
  }
}
