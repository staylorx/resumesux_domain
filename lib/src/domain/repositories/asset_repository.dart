import 'package:fpdart/fpdart.dart';
import '../../../../src/core/failure.dart';
import '../entities/asset.dart';

/// Repository for asset-related operations.
abstract class AssetRepository {
  /// Retrieves all assets.
  Future<Either<Failure, List<Asset>>> getAllAssets();
}
