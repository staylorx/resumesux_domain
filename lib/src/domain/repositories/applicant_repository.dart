import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Repository for applicant-related operations.
abstract class ApplicantRepository {
  /// Retrieves the applicant with updated information.
  Future<Either<Failure, Applicant>> getApplicant({
    required Applicant applicant,
  });
}
