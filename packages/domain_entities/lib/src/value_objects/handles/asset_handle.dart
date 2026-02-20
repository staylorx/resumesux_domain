// domain/value_objects/asset_handle.dart - Domain-opaque handle
import 'package:uuid/uuid.dart';

class AssetHandle {
  final String _value;

  const AssetHandle(this._value);

  // Factory for use cases to generate handles
  factory AssetHandle.generate() => AssetHandle(const Uuid().v4());

  // Parse from CLI input/string
  factory AssetHandle.fromString(String value) => AssetHandle(value);

  @override
  String toString() => _value; // CLI-friendly output

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AssetHandle && _value == other._value;

  @override
  int get hashCode => _value.hashCode;
}
