import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';

import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for retrieving and enriching applicant information.
class GetApplicantUsecase with Loggable {
  final ApplicantRepository applicantRepository;

  /// Creates a new instance of [GetApplicantUsecase].
  GetApplicantUsecase({Logger? logger, required this.applicantRepository}) {
    this.logger = logger;
  }

  /// Enriches the provided applicant with additional data from the digest.
  ///
  /// Parameters:
  /// - [applicant]: The applicant to enrich.
  ///
  /// Returns: [Either<Failure, Applicant>] containing the enriched applicant or a failure.
  Future<Either<Failure, Applicant>> call({
    required Applicant applicant,
  }) async {
    logger?.info(
      '[GetApplicantUsecase] Enriching applicant information with digest data',
    );
    final result = await applicantRepository.getApplicant(applicant: applicant);
    result.fold(
      (failure) => logger?.error(
        '[GetApplicantUsecase] Failed to enrich applicant: ${failure.message}',
      ),
      (enrichedApplicant) => logger?.info(
        '[GetApplicantUsecase] Applicant enriched successfully: ${enrichedApplicant.name}',
      ),
    );
    return result;
  }
}
