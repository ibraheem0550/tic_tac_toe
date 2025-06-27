import 'dart:developer' as developer;

/// خدمة تسجيل الأخطاء والرسائل
class Logger {
  static void logError(String message,
      [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: 'TicTacToe',
      error: error,
      stackTrace: stackTrace,
      level: 1000, // SEVERE level
    );
  }

  static void logWarning(String message) {
    developer.log(
      message,
      name: 'TicTacToe',
      level: 900, // WARNING level
    );
  }

  static void logInfo(String message) {
    developer.log(
      message,
      name: 'TicTacToe',
      level: 800, // INFO level
    );
  }

  static void logDebug(String message) {
    developer.log(
      message,
      name: 'TicTacToe',
      level: 700, // CONFIG level
    );
  }
}
