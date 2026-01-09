import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Repository for digest-related operations.
abstract class DigestRepository {
  /// Retrieves all digests.
  Future<Either<Failure, List<Digest>>> getAllDigests();
}
