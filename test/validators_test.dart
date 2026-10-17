import 'package:flutter_test/flutter_test.dart';

import 'package:edupulse/core/utils/validators.dart';

void main() {
  group('validateEmail', () {
    test('rejects empty input', () {
      expect(AppValidators.validateEmail(null), 'Email is required.');
      expect(AppValidators.validateEmail('   '), 'Email is required.');
    });

    test('accepts valid addresses', () {
      for (final email in [
        'student@edupulse.com',
        'first.last+tag@mail.example.co.uk',
        '  padded@example.org  ',
      ]) {
        expect(AppValidators.validateEmail(email), isNull, reason: email);
      }
    });

    test('rejects invalid addresses', () {
      for (final email in [
        'no-at-sign.com',
        'user@',
        '@example.com',
        'user@example',
        'user@example.c',
        'user@example.com extra',
        'user,name@example.com',
      ]) {
        expect(
          AppValidators.validateEmail(email),
          'Please enter a valid email address.',
          reason: email,
        );
      }
    });
  });

  group('validatePassword', () {
    test('rejects empty input', () {
      expect(AppValidators.validatePassword(null), 'Password is required.');
      expect(AppValidators.validatePassword(''), 'Password is required.');
    });

    test('rejects short passwords', () {
      expect(
        AppValidators.validatePassword('Ab1!'),
        'Password must be at least 8 characters long.',
      );
    });

    test('requires every character class', () {
      for (final password in [
        'abcdefg1!', // no uppercase
        'ABCDEFG1!', // no lowercase
        'Abcdefgh!', // no digit
        'Abcdefgh1', // no special character
      ]) {
        expect(
          AppValidators.validatePassword(password),
          'Must contain uppercase, lowercase, number, and special character.',
          reason: password,
        );
      }
    });

    test('accepts strong passwords', () {
      expect(AppValidators.validatePassword('Str0ng!Pass'), isNull);
    });
  });

  group('validateName', () {
    test('rejects empty or too short names', () {
      expect(AppValidators.validateName(null), 'Name is required.');
      expect(AppValidators.validateName('  '), 'Name is required.');
      expect(
        AppValidators.validateName(' A '),
        'Name must be at least 2 characters long.',
      );
    });

    test('accepts valid names', () {
      expect(AppValidators.validateName('Al'), isNull);
    });
  });
}
