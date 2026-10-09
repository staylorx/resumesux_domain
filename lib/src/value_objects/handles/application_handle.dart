import 'package:equatable/equatable.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// An [ApplicationHandle] paired with the [Application] it references.
class ApplicationWithHandle {
  /// The application's handle.
  final ApplicationHandle handle;

  /// The application referenced by [handle].
  final Application application;

  /// Creates an [ApplicationWithHandle] for the given handle and application.
  ApplicationWithHandle({required this.handle, required this.application});
}

/// An immutable identifier for an application.
class ApplicationHandle with EquatableMixin {
  /// The raw handle value.
  final String value;

  /// Creates an [ApplicationHandle] wrapping the given value.
  const ApplicationHandle(this.value);

  @override
  String toString() => value;

  @override
  List<Object?> get props => [value];
}
