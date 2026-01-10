/// Base abstract class for representing failures in functional programming patterns,
/// such as those used with the Either type from the dartz package.
/// This class provides a standard way to encapsulate error information.
abstract class Failure {
  /// The error message describing the failure.
  final String message;

  /// Creates a [Failure] with the given [message].
  const Failure({required this.message});
}

class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message});
}

class PermissionFailure extends Failure {
  const PermissionFailure({required super.message});
}

class ServiceFailure extends Failure {
  const ServiceFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

class ParsingFailure extends Failure {
  const ParsingFailure({required super.message});
}

class DatabaseConnectionFailure extends Failure {
  const DatabaseConnectionFailure({required super.message});
}

class DatabaseReadFailure extends Failure {
  const DatabaseReadFailure({required super.message});
}

class DatabaseWriteFailure extends Failure {
  const DatabaseWriteFailure({required super.message});
}

class DatabaseConstraintFailure extends Failure {
  const DatabaseConstraintFailure({required super.message});
}

class DataParsingFailure extends Failure {
  const DataParsingFailure({required super.message});
}

class PlatformFailure extends Failure {
  const PlatformFailure({required super.message});
}

class EnvironmentFailure extends Failure {
  const EnvironmentFailure({required super.message});
}

class ConfigPathFailure extends Failure {
  const ConfigPathFailure({required super.message});
}