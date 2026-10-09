import 'package:equatable/equatable.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// An [AssetHandle] paired with the [Asset] it references.
class AssetWithHandle {
  /// The asset's handle.
  final AssetHandle handle;

  /// The asset referenced by [handle].
  final Asset asset;

  /// Creates an [AssetWithHandle] for the given handle and asset.
  AssetWithHandle({required this.handle, required this.asset});
}

/// An immutable identifier for an asset.
class AssetHandle with EquatableMixin {
  /// The raw handle value.
  final String value;

  /// Creates an [AssetHandle] wrapping the given value.
  const AssetHandle(this.value);

  @override
  String toString() => value; // CLI-friendly output

  @override
  List<Object?> get props => [value];
}
