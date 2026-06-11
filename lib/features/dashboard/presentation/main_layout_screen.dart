import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_screen.dart';
import 'my_courses_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../../core/theme/theme_provider.dart';

class MainLayoutScreen extends ConsumerStatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  ConsumerState<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends ConsumerState<MainLayoutScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    MyCoursesScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.sizeOf(context).width > 600;

    if (!kIsWeb) {
      // Native Mobile layout
      return Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onItemTapped,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.play_circle_outline),
              selectedIcon: Icon(Icons.play_circle_filled),
              label: 'My Courses',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      );
    }

    // Web Layout
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final logo = InkWell(
      onTap: () => _onItemTapped(0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/logo.png', height: 40, errorBuilder: (c,e,s) => const Icon(Icons.school)),
          const SizedBox(width: 8),
          const Text('EduPulse', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !isWideScreen,
        title: isWideScreen ? logo : const Text('EduPulse'),
        actions: [
          if (isWideScreen) ...[
            TextButton(
              onPressed: () => _onItemTapped(0),
              child: Text(
                'Home', 
                style: TextStyle(
                  fontWeight: _currentIndex == 0 ? FontWeight.bold : FontWeight.normal,
                  color: Theme.of(context).colorScheme.onSurface,
                )
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => _onItemTapped(1),
              child: Text(
                'My Courses', 
                style: TextStyle(
                  fontWeight: _currentIndex == 1 ? FontWeight.bold : FontWeight.normal,
                  color: Theme.of(context).colorScheme.onSurface,
                )
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => _onItemTapped(2),
              child: Text(
                'Profile', 
                style: TextStyle(
                  fontWeight: _currentIndex == 2 ? FontWeight.bold : FontWeight.normal,
                  color: Theme.of(context).colorScheme.onSurface,
                )
              ),
            ),
            const SizedBox(width: 16),
          ],
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ref.read(themeModeProvider.notifier).setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: isWideScreen ? null : Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/logo.png', height: 60, errorBuilder: (c,e,s) => const Icon(Icons.school, size: 60)),
                  const Spacer(),
                  const Text('EduPulse', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              selected: _currentIndex == 0,
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.play_circle_filled),
              title: const Text('My Courses'),
              selected: _currentIndex == 1,
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              selected: _currentIndex == 2,
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _screens[_currentIndex]),
          // Minimal footer
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            width: double.infinity,
            child: const Center(
              child: Text(
                '© 2026 EduPulse. All rights reserved.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
