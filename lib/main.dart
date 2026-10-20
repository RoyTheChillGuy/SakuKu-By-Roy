import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/page_transitions.dart';
import 'data/services/database_seeder.dart';
import 'data/services/isar_service.dart';
import 'data/services/notification_service.dart';
import 'core/services/widget_service.dart';
import 'presentation/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');

  await IsarService.initialize();
  await DatabaseSeeder().seedIfEmpty();
  await WidgetLaunchService.instance.initialize();
  try {
    await NotificationService.instance.initialize();
  } catch (_) {
    // Notifications optional — app must still launch if scheduling fails.
  }

  runApp(const ProviderScope(child: SakuKuApp()));
}

class SakuKuApp extends StatelessWidget {
  const SakuKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    const transitions = PageTransitionsTheme(
      builders: {
        TargetPlatform.android: SoftFadePageTransitionsBuilder(),
        TargetPlatform.iOS: SoftFadePageTransitionsBuilder(),
        TargetPlatform.windows: SoftFadePageTransitionsBuilder(),
        TargetPlatform.macOS: SoftFadePageTransitionsBuilder(),
        TargetPlatform.linux: SoftFadePageTransitionsBuilder(),
        TargetPlatform.fuchsia: SoftFadePageTransitionsBuilder(),
      },
    );

    return MaterialApp(
      title: 'SakuKu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light.copyWith(pageTransitionsTheme: transitions),
      darkTheme: AppTheme.dark.copyWith(pageTransitionsTheme: transitions),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
