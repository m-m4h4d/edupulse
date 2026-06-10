import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edupulse/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: EduPulseApp()));

    // This default test expects a counter. Since we removed it, we'll just test that the app loads.
    expect(find.text('Dashboard Placeholder'), findsNothing); // Will be nothing until we navigate, actually it's login screen first.
    expect(find.text('Welcome Back'), findsOneWidget); // Login screen title
  });
}
