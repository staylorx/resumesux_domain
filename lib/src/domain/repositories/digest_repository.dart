import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Repository for digest-related operations.
abstract class DigestRepository {
  /// Retrieves all digests.
  Future<Either<Failure, List<Digest>>> getAllDigests();

  /// Gets the gig repository.
  GigRepository get gigRepository;

  /// Gets the asset repository.
  AssetRepository get assetRepository;

  /// Saves the AI responses JSON for gigs to the database.
  Future<Either<Failure, Unit>> saveGigAiResponse({
    required String aiResponseJson,
    required String jobReqId,
  });

  /// Saves the AI responses JSON for assets to the database.
  Future<Either<Failure, Unit>> saveAssetAiResponse({
    required String aiResponseJson,
    required String jobReqId,
  });
}
