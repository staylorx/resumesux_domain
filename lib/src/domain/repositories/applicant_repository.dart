import 'package:fpdart/fpdart.dart';
import '../../../../src/core/failure.dart';
import '../entities/applicant.dart';

/// Repository for applicant-related operations.
abstract class ApplicantRepository {
  /// Retrieves the applicant with updated information.
  Future<Either<Failure, Applicant>> getApplicant({
    required Applicant applicant,
  });
}
