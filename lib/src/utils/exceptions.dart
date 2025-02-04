class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException(this.message, {this.code});

  @override
  String toString() => 'AuthException: $message${code != null ? ' (Code: $code)' : ''}';
}

class UserException implements Exception {
  final String message;
  final String? code;

  UserException(this.message, {this.code});

  @override
  String toString() => 'UserException: $message${code != null ? ' (Code: $code)' : ''}';
}

// Helper function to convert Firebase Auth errors to user-friendly messages
String getAuthErrorMessage(String code) {
  switch (code) {
    case 'user-not-found':
      return 'No user found with this email address';
    case 'wrong-password':
      return 'Incorrect password';
    case 'email-already-in-use':
      return 'An account already exists with this email';
    case 'invalid-email':
      return 'Please enter a valid email address';
    case 'weak-password':
      return 'Password is too weak';
    case 'operation-not-allowed':
      return 'This operation is not allowed';
    case 'user-disabled':
      return 'This account has been disabled';
    default:
      return 'An error occurred. Please try again';
  }
} 