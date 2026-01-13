import 'package:logger/logger.dart' as logger_pkg;
import 'package:resumesux_domain/resumesux_domain.dart';

/// Implementation of Logger using the logger package for console output.
class ConsoleLoggerImpl implements Logger {
  @override
  final String? name;

  final logger_pkg.Logger _logger;

  ConsoleLoggerImpl({this.name})
    : _logger = logger_pkg.Logger(
        printer: logger_pkg.PrettyPrinter(
          methodCount: 0,
          errorMethodCount: 5,
          lineLength: 50,
          colors: true,
          printEmojis: true,
          // ignore: deprecated_member_use
          printTime: true,
        ),
      );

  @override
  void log(LogLevel level, String message) {
    switch (level) {
      case LogLevel.debug:
        _logger.d(message);
        break;
      case LogLevel.info:
        _logger.i(message);
        break;
      case LogLevel.warning:
        _logger.w(message);
        break;
      case LogLevel.error:
        _logger.e(message);
        break;
    }
  }

  @override
  void debug(String message) => log(LogLevel.debug, message);

  @override
  void info(String message) => log(LogLevel.info, message);

  @override
  void warn(String message) => log(LogLevel.warning, message);

  @override
  void error(String message) => log(LogLevel.error, message);
}
