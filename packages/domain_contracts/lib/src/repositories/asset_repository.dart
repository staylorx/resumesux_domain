import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';
import 'package:resumesux_domain/src/domain/value_objects/handles/asset_handle.dart';

// Projection for CLI output
class AssetWithHandle {
  final AssetHandle handle;
  final Asset asset;
  AssetWithHandle({required this.handle, required this.asset});
}

/// Repository for asset-related operations.
abstract class AssetRepository {
  /// Retrieves all assets.
  Future<Either<Failure, List<Asset>>> getAllAssets();

  Future<Either<Failure, List<AssetWithHandle>>> getAll(); // For listing

  /// Retrieves the last AI responses as JSON string.
  String? getLastAiResponsesJson();

  /// Saves the AI responses JSON for assets to the database.
  Future<Either<Failure, Unit>> saveAiResponse({
    required String aiResponseJson,
    required String jobReqId,
  });
}
