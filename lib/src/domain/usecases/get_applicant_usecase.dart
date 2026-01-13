import 'package:fpdart/fpdart.dart';

import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for retrieving  applicant information from database
class GetApplicantUsecase with Loggable {
  final ApplicantRepository applicantRepository;

  /// Creates a new instance of [GetApplicantUsecase].
  GetApplicantUsecase({Logger? logger, required this.applicantRepository}) {
    this.logger = logger;
  }

  /// get the applicant record from database
  Future<Either<Failure, Applicant>> call(ApplicantHandle handle) async {
    logger?.info(
      '[GetApplicantUsecase] getting applicant information from database',
    );
    final result = await applicantRepository.getByHandle(handle: handle);
    result.match(
      (failure) => logger?.error(
        '[GetApplicantUsecase] Failed to get applicant: ${failure.message}',
      ),
      (_) => {},
    );
    return result;
  }
}
