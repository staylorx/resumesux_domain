import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

// Projection for CLI output
class ApplicantWithHandle {
  final ApplicantHandle handle;
  final Applicant applicant;
  ApplicantWithHandle({required this.handle, required this.applicant});
}

/// Repository for applicant-related operations.
abstract class ApplicantRepository {
  /// Imports gigs and assets from the specified digest path and associates them with the applicant.
  Future<Either<Failure, Applicant>> importDigest({
    required Applicant applicant,
    required String digestPath,
  });

  Future<Either<Failure, Unit>> save({
    required ApplicantHandle handle,
    required Applicant applicant,
  });
  Future<Either<Failure, Applicant>> getByHandle({
    required ApplicantHandle handle,
  });
  Future<Either<Failure, List<ApplicantWithHandle>>> getAll(); // For listing
  Future<Either<Failure, Unit>> remove({required ApplicantHandle handle});
}
