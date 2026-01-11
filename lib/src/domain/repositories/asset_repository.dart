import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Repository for asset-related operations.
abstract class AssetRepository {
  /// Retrieves all assets.
  Future<Either<Failure, List<Asset>>> getAllAssets();

  /// Retrieves the last AI responses as JSON string.
  String? getLastAiResponsesJson();

  /// Saves the AI responses JSON for assets to the database.
  Future<Either<Failure, Unit>> saveAiResponse({
    required String aiResponseJson,
    required String jobReqId,
  });
}
