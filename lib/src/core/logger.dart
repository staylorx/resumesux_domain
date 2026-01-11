import 'package:logging/logging.dart';

/// A factory for creating loggers.
class LoggerFactory {
  /// Creates a logger with the given name.
  static Logger create({required String name}) => Logger(name);
}
