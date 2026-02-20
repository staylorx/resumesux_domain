// domain/value_objects/task_handle.dart - Domain-opaque handle
import 'package:uuid/uuid.dart';

class ApplicationHandle {
  final String _value;

  const ApplicationHandle(this._value);

  // Factory for use cases to generate handles
  factory ApplicationHandle.generate() => ApplicationHandle(const Uuid().v4());

  // Parse from CLI input/string
  factory ApplicationHandle.fromString(String value) =>
      ApplicationHandle(value);

  @override
  String toString() => _value; // CLI-friendly output

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApplicationHandle && _value == other._value;

  @override
  int get hashCode => _value.hashCode;
}
