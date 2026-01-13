import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Repository for applicant-related operations.
abstract class ApplicantRepository {
  /// Retrieves the applicant with updated information.
  Future<Either<Failure, Applicant>> getApplicant({
    required Applicant applicant,
  });

  /// Saves the applicant to persistent storage.
  ///
  /// Parameters:
  /// - [applicant]: The applicant to save.
  ///
  /// Returns: [Future<Either<Failure, Unit>>] indicating success or failure.
  Future<Either<Failure, Unit>> saveApplicant({required Applicant applicant});

  /// Imports gigs and assets from the specified digest path and associates them with the applicant.
  ///
  /// Parameters:
  /// - [applicant]: The applicant to update.
  /// - [digestPath]: The path to the digest folder containing gigs and assets.
  ///
  /// Returns: [Future<Either<Failure, Applicant>>] with the updated applicant or failure.
  Future<Either<Failure, Applicant>> importDigest({
    required Applicant applicant,
    required String digestPath,
  });
}
