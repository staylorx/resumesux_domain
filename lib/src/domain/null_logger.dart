import 'package:resumesux_domain/resumesux_domain.dart';

// purposefully does nothing
class NullLogger implements Logger {
  @override
  final String? name;

  const NullLogger({this.name});

  @override
  void log(LogLevel level, String message) {}
  @override
  void info(String message) {}
  @override
  void debug(String message) {}
  @override
  void error(String message) {}
  @override
  void warn(String message) {}
}
