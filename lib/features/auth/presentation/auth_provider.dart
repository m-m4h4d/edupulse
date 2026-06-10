import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for SharedPreferences to be accessible synchronously
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

// The state of our authentication
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error
}

class AuthNotifier extends Notifier<AuthState> {
  static const String _authKey = 'is_authenticated';

  @override
  AuthState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final isAuthenticated = prefs.getBool(_authKey) ?? false;
    return isAuthenticated ? AuthState.authenticated : AuthState.unauthenticated;
  }

  Future<void> login(String email, String password) async {
    state = AuthState.loading;
    try {
      // Simulate network request
      await Future.delayed(const Duration(seconds: 2));
      
      // Basic mock validation
      if (email.isNotEmpty && password.isNotEmpty) {
        final prefs = ref.read(sharedPreferencesProvider);
        await prefs.setBool(_authKey, true);
        state = AuthState.authenticated;
      } else {
        state = AuthState.error;
      }
    } catch (e) {
      state = AuthState.error;
    }
  }

  Future<void> signup(String name, String email, String password) async {
    state = AuthState.loading;
    try {
      // Simulate network request
      await Future.delayed(const Duration(seconds: 2));
      
      // Basic mock validation
      if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
        final prefs = ref.read(sharedPreferencesProvider);
        await prefs.setBool(_authKey, true);
        state = AuthState.authenticated;
      } else {
        state = AuthState.error;
      }
    } catch (e) {
      state = AuthState.error;
    }
  }

  Future<void> logout() async {
    state = AuthState.loading;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_authKey);
    state = AuthState.unauthenticated;
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
