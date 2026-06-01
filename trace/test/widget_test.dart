import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:trace/core/theme/trace_theme.dart';
import 'package:trace/navigation/app_shell.dart';

void main() {
  testWidgets('App shell shows TRACE navigation', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TraceTheme.light,
        home: const AppShell(),
      ),
    );

    expect(find.text('TRACE'), findsOneWidget);
    expect(find.text('TASKS'), findsOneWidget);
    expect(find.text('PLAN'), findsOneWidget);
    expect(find.text('STATS'), findsOneWidget);
    expect(find.text('SYS'), findsOneWidget);
  });
}
