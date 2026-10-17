import 'package:flutter_test/flutter_test.dart';

import 'package:edupulse/features/auth/presentation/auth_provider.dart';

void main() {
  group('AuthState.copyWith', () {
    const withError = AuthState(
      isAuthenticated: false,
      isLoading: false,
      errorMessage: 'Invalid credentials',
    );

    test('keeps the error message when not passed', () {
      expect(withError.copyWith(isLoading: true).errorMessage, 'Invalid credentials');
    });

    test('clears the error message when null is passed', () {
      expect(withError.copyWith(errorMessage: null).errorMessage, isNull);
    });

    test('replaces the error message', () {
      expect(withError.copyWith(errorMessage: 'Other').errorMessage, 'Other');
    });
  });
}
