import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'core/theme/theme_provider.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Load color scheme from logo
  const imageProvider = AssetImage('assets/logo.png');
  final lightColorScheme = await ColorScheme.fromImageProvider(
    provider: imageProvider,
    brightness: Brightness.light,
  );
  final darkColorScheme = await ColorScheme.fromImageProvider(
    provider: imageProvider,
    brightness: Brightness.dark,
  );

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: EduPulseApp(
        lightColorScheme: lightColorScheme,
        darkColorScheme: darkColorScheme,
      ),
    ),
  );
}

class EduPulseApp extends ConsumerWidget {
  final ColorScheme lightColorScheme;
  final ColorScheme darkColorScheme;

  const EduPulseApp({
    super.key,
    required this.lightColorScheme,
    required this.darkColorScheme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'EduPulse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: lightColorScheme,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: darkColorScheme,
        useMaterial3: true,
      ),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
