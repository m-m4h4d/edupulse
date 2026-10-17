import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edupulse/main.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:edupulse/features/auth/presentation/auth_provider.dart';

void main() {
  testWidgets('App starts on the login screen', (WidgetTester tester) async {
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

    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
