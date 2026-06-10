import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for SharedPreferences to be accessible synchronously
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

class UserModel {
  final String name;
  final String email;
  final String? profilePicturePath;

  UserModel({
    required this.name,
    required this.email,
    this.profilePicturePath,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? profilePicturePath,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
    );
  }
}

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;
  final UserModel? user;

  const AuthState({
    required this.isAuthenticated,
    required this.isLoading,
    this.errorMessage,
    this.user,
  });

  factory AuthState.initial() => const AuthState(isAuthenticated: false, isLoading: false);
  
  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
    UserModel? user,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  static const String _authKey = 'is_authenticated';
  static const String _nameKey = 'user_name';
  static const String _emailKey = 'user_email';
  static const String _pfpKey = 'user_pfp';

  @override
  AuthState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final isAuthenticated = prefs.getBool(_authKey) ?? false;
    
    if (isAuthenticated) {
      final name = prefs.getString(_nameKey) ?? 'Student Name';
      final email = prefs.getString(_emailKey) ?? 'student@edupulse.com';
      final pfp = prefs.getString(_pfpKey);
      return AuthState(
        isAuthenticated: true, 
        isLoading: false,
        user: UserModel(name: name, email: email, profilePicturePath: pfp),
      );
    }
    
    return AuthState.initial();
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      if (email.isNotEmpty && password.isNotEmpty) {
        final prefs = ref.read(sharedPreferencesProvider);
        await prefs.setBool(_authKey, true);
        await prefs.setString(_emailKey, email);
        
        final name = prefs.getString(_nameKey) ?? 'Student Name';
        final pfp = prefs.getString(_pfpKey);
        
        state = state.copyWith(
          isLoading: false, 
          isAuthenticated: true,
          user: UserModel(name: name, email: email, profilePicturePath: pfp),
        );
      } else {
        state = state.copyWith(isLoading: false, errorMessage: 'Invalid credentials');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Error logging in');
    }
  }

  Future<void> signup(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
        final prefs = ref.read(sharedPreferencesProvider);
        await prefs.setBool(_authKey, true);
        await prefs.setString(_nameKey, name);
        await prefs.setString(_emailKey, email);
        
        state = state.copyWith(
          isLoading: false, 
          isAuthenticated: true,
          user: UserModel(name: name, email: email, profilePicturePath: null),
        );
      } else {
        state = state.copyWith(isLoading: false, errorMessage: 'Invalid details');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Error signing up');
    }
  }

  Future<void> updateProfilePicture(String path) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_pfpKey, path);
    if (state.user != null) {
      state = state.copyWith(
        user: state.user!.copyWith(profilePicturePath: path),
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_authKey);
    state = AuthState.initial();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
