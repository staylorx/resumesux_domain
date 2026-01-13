import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for removing an applicant
class RemoveApplicantUsecase with Loggable {
  final ApplicantRepository applicantRepository;

  /// Creates a new instance of [RemoveApplicantUsecase].
  RemoveApplicantUsecase({Logger? logger, required this.applicantRepository}) {
    this.logger = logger;
  }

  /// Remove the applicant
  Future<Either<Failure, Unit>> call({required ApplicantHandle handle}) async {
    logger?.info(
      '[RemoveApplicantUsecase] removing applicant ${handle.toString()}',
    );
    final result = await applicantRepository.remove(handle: handle);
    result.match(
      (failure) => logger?.error(
        '[RemoveApplicantUsecase] Failed to remove applicant: ${failure.message}',
      ),
      (_) => {},
    );
    return result;
  }
}
