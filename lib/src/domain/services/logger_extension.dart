import 'package:resumesux_domain/resumesux_domain.dart';

extension LoggerExtension on Logger {
  void log<T>(String method, String message) {
    info('${T.toString()}.$method: $message');
  }
}
