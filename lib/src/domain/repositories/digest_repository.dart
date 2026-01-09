import 'package:fpdart/fpdart.dart';
import 'package:resume_suckage_domain/resume_suckage_domain.dart';

/// Repository for digest-related operations.
abstract class DigestRepository {
  /// Retrieves all digests.
  Future<Either<Failure, List<Digest>>> getAllDigests();
}
