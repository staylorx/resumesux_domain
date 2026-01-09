// ignore_for_file: avoid_print

import 'dart:io';

import 'package:logging/logging.dart';

/// Initializes the logging system with an optional log level.
/// If no level is provided, it reads from the LOG_LEVEL environment variable (default: INFO).
void initLogging({Level? level}) => LoggerFactory.init(level: level);

class LoggerFactory {
  static Level _parseLevel(String level) {
    switch (level.toUpperCase()) {
      case 'ALL':
        return Level.ALL;
      case 'FINEST':
        return Level.FINEST;
      case 'FINER':
        return Level.FINER;
      case 'FINE':
        return Level.FINE;
      case 'CONFIG':
        return Level.CONFIG;
      case 'INFO':
        return Level.INFO;
      case 'WARNING':
        return Level.WARNING;
      case 'SEVERE':
        return Level.SEVERE;
      case 'SHOUT':
        return Level.SHOUT;
      case 'OFF':
        return Level.OFF;
      default:
        return Level.INFO;
    }
  }

  static void init({Level? level}) {
    Logger.root.level =
        level ?? _parseLevel(Platform.environment['LOG_LEVEL'] ?? 'INFO');
    Logger.root.onRecord.listen((record) {
      print(
        '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}',
      );
    });
  }

  static Logger create(String name) => Logger(name);
}
