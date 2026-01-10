import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Repository for asset-related operations.
abstract class AssetRepository {
  /// Retrieves all assets.
  Future<Either<Failure, List<Asset>>> getAllAssets();
}
