/// Enum representing different log levels.
enum LogLevel { debug, info, warning, error }

/// Abstract port for logging functionality.
abstract class Logger {
  /// The optional name of the logger.
  String? get name;

  /// Log a message at the specified level.
  void log(LogLevel level, String message);

  /// Convenience method for debug level logging.
  void debug(String message);

  /// Convenience method for info level logging.
  void info(String message);

  /// Alias for warning level logging.
  void warn(String message);

  /// Convenience method for error level logging.
  void error(String message);
}
