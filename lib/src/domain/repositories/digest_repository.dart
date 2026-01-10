import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Repository for digest-related operations.
abstract class DigestRepository {
  /// Retrieves all digests.
  Future<Either<Failure, List<Digest>>> getAllDigests();

  /// Saves the last AI response for gigs to the specified file path.
  Future<Either<Failure, Unit>> saveGigAiResponse({required String filePath});

  /// Saves the last AI response for assets to the specified file path.
  Future<Either<Failure, Unit>> saveAssetAiResponse({required String filePath});
}
