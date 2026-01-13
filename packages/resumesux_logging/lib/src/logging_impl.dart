import 'package:logging/logging.dart' as logging_pkg;
import 'package:resumesux_domain/resumesux_domain.dart';

/// Implementation of Logger using the logging package.
class LoggerImpl implements Logger {
  @override
  final String name;

  final logging_pkg.Logger _logger;

  LoggerImpl({required this.name}) : _logger = logging_pkg.Logger(name);

  @override
  void log(LogLevel level, String message) {
    switch (level) {
      case LogLevel.debug:
        _logger.fine(message);
        break;
      case LogLevel.info:
        _logger.info(message);
        break;
      case LogLevel.warning:
        _logger.warning(message);
        break;
      case LogLevel.error:
        _logger.severe(message);
        break;
    }
  }

  @override
  void debug(String message) => log(LogLevel.debug, message);

  void fine(String message) => log(LogLevel.debug, message);

  @override
  void info(String message) => log(LogLevel.info, message);

  @override
  void warn(String message) => log(LogLevel.warning, message);

  @override
  void error(String message) => log(LogLevel.error, message);
}
