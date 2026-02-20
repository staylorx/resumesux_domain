// domain/value_objects/task_handle.dart - Domain-opaque handle
import 'package:uuid/uuid.dart';

class JobReqHandle {
  final String _value;

  const JobReqHandle(this._value);

  // Factory for use cases to generate handles
  factory JobReqHandle.generate() => JobReqHandle(const Uuid().v4());

  // Parse from CLI input/string
  factory JobReqHandle.fromString(String value) => JobReqHandle(value);

  @override
  String toString() => _value; // CLI-friendly output

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is JobReqHandle && _value == other._value;

  @override
  int get hashCode => _value.hashCode;
}
