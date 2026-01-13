import 'dart:io';
import 'package:logger/logger.dart' as logger_pkg;
import 'package:resumesux_domain/resumesux_domain.dart';

/// Custom log printer that writes to a file.
class FileLogPrinter implements logger_pkg.LogPrinter {
  final String filePath;

  FileLogPrinter(this.filePath);

  @override
  Future<void> init() async {}

  @override
  Future<void> destroy() async {}

  @override
  List<String> log(logger_pkg.LogEvent event) {
    final file = File(filePath);
    final message = '${event.time} [${event.level.name}] ${event.message}\n';
    file.writeAsStringSync(message, mode: FileMode.append);
    return []; // No console output
  }
}

/// Implementation of Logger using the logger package for file output.
class FileLoggerImpl implements Logger {
  @override
  final String? name;

  final logger_pkg.Logger _logger;

  FileLoggerImpl({String filePath = 'app.log', this.name})
    : _logger = logger_pkg.Logger(printer: FileLogPrinter(filePath));

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

  void fine(String message) => log(LogLevel.debug, message);

  @override
  void info(String message) => log(LogLevel.info, message);

  @override
  void warn(String message) => log(LogLevel.warning, message);

  @override
  void error(String message) => log(LogLevel.error, message);
}
