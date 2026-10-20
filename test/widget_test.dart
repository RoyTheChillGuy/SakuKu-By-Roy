import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sakuku_app/core/theme/app_theme.dart';

void main() {
  testWidgets('SakuKu theme MaterialApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const Scaffold(body: Center(child: Text('SakuKu'))),
      ),
    );

    expect(find.text('SakuKu'), findsOneWidget);
  });
}
