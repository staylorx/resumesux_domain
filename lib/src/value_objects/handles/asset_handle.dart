// domain/value_objects/asset_handle.dart - Domain-opaque handle

import 'package:equatable/equatable.dart';

class AssetHandle with EquatableMixin {
  final String value;

  const AssetHandle(this.value);

  @override
  String toString() => value; // CLI-friendly output

  @override
  List<Object?> get props => [value];
}
