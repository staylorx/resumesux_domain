import 'package:equatable/equatable.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

class AssetWithHandle {
  final AssetHandle handle;
  final Asset asset;
  AssetWithHandle({required this.handle, required this.asset});
}

class AssetHandle with EquatableMixin {
  final String value;

  const AssetHandle(this.value);

  @override
  String toString() => value; // CLI-friendly output

  @override
  List<Object?> get props => [value];
}
