import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for updating an applicant
class UpdateApplicantUsecase with Loggable {
  final ApplicantRepository applicantRepository;

  /// Creates a new instance of [UpdateApplicantUsecase].
  UpdateApplicantUsecase({Logger? logger, required this.applicantRepository}) {
    this.logger = logger;
  }

  /// Update the applicant
  Future<Either<Failure, Unit>> call({
    required ApplicantHandle handle,
    required Applicant applicant,
  }) async {
    logger?.info(
      '[UpdateApplicantUsecase] updating applicant ${handle.toString()}',
    );
    final result = await applicantRepository.save(
      handle: handle,
      applicant: applicant,
    );
    result.match(
      (failure) => logger?.error(
        '[UpdateApplicantUsecase] Failed to update applicant: ${failure.message}',
      ),
      (_) => {},
    );
    return result;
  }
}
