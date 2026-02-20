// domain/value_objects/gig_handle.dart - Domain-opaque handle
import 'package:uuid/uuid.dart';

class GigHandle {
  final String _value;

  const GigHandle(this._value);

  // Factory for use cases to generate handles
  factory GigHandle.generate() => GigHandle(const Uuid().v4());

  // Parse from CLI input/string
  factory GigHandle.fromString(String value) => GigHandle(value);

  @override
  String toString() => _value; // CLI-friendly output

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is GigHandle && _value == other._value;

  @override
  int get hashCode => _value.hashCode;
}
