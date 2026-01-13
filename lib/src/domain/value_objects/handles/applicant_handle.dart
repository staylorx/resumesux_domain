// domain/value_objects/task_handle.dart - Domain-opaque handle
import 'package:uuid/uuid.dart';

class ApplicantHandle {
  final String _value;

  const ApplicantHandle(this._value);

  // Factory for use cases to generate handles
  factory ApplicantHandle.generate() => ApplicantHandle(const Uuid().v4());

  // Parse from CLI input/string
  factory ApplicantHandle.fromString(String value) => ApplicantHandle(value);

  @override
  String toString() => _value; // CLI-friendly output

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApplicantHandle && _value == other._value;

  @override
  int get hashCode => _value.hashCode;
}
