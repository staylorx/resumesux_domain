import 'package:resumesux_domain/resumesux_domain.dart';

/// Mixin that provides an optional logger for injection into repositories and use cases.
mixin Loggable {
  /// The optional logger instance.
  Logger? logger;
}
