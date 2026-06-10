class AppValidators {
  static const String _emailPattern =
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
  static const String _passwordPattern =
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';

  /// Validates standard email format
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }
    final regex = RegExp(_emailPattern);
    if (!regex.hasMatch(value.trim())) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  /// Validates strong password rules: 
  /// Minimum 8 chars, 1 Upper, 1 Lower, 1 Number, 1 Special Char
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    final regex = RegExp(_passwordPattern);
    if (!regex.hasMatch(value)) {
      return 'Must contain uppercase, lowercase, number, and special character.';
    }
    return null;
  }

  /// Validates standard name input
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required.';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long.';
    }
    return null;
  }
}
