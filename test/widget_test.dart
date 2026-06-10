import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edupulse/main.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:edupulse/features/auth/presentation/auth_provider.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: EduPulseApp(
        lightColorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
        darkColorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
      ),
      ),
    );

    // This default test expects a counter. Since we removed it, we'll just test that the app loads.
    expect(find.text('Dashboard Placeholder'), findsNothing); // Will be nothing until we navigate, actually it's login screen first.
    expect(find.text('Welcome Back'), findsOneWidget); // Login screen title
  });
}
