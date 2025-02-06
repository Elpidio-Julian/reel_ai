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

class VideoException implements Exception {
  // Video error codes
  static const String videoTooLarge = 'video-too-large';
  static const String unsupportedFormat = 'unsupported-format';
  static const String userNotAuthenticated = 'user-not-authenticated';
  static const String videoNotFound = 'video-not-found';
  static const String unauthorized = 'unauthorized';
  static const String uploadFailed = 'upload-failed';
  static const String deleteFailed = 'delete-failed';
  
  final String message;
  final String? code;

  VideoException(this.message, {this.code});

  @override
  String toString() => 'VideoException: $message${code != null ? ' (Code: $code)' : ''}';

  // Helper function to convert video error codes to user-friendly messages
  static String getVideoErrorMessage(String code) {
    switch (code) {
      case videoTooLarge:
        return 'Video size exceeds maximum limit';
      case unsupportedFormat:
        return 'Video format is not supported';
      case userNotAuthenticated:
        return 'Please sign in to continue';
      case videoNotFound:
        return 'Video not found';
      case unauthorized:
        return 'You are not authorized to perform this action';
      case uploadFailed:
        return 'Failed to upload video';
      case deleteFailed:
        return 'Failed to delete video';
      default:
        return 'An error occurred with the video';
    }
  }
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