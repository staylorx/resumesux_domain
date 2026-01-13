import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for retrieving all applicants
class GetAllApplicantsUsecase with Loggable {
  final ApplicantRepository applicantRepository;

  /// Creates a new instance of [GetAllApplicantsUsecase].
  GetAllApplicantsUsecase({Logger? logger, required this.applicantRepository}) {
    this.logger = logger;
  }

  /// Get all applicants
  Future<Either<Failure, List<ApplicantWithHandle>>> call() async {
    logger?.info('[GetAllApplicantsUsecase] getting all applicants');
    final result = await applicantRepository.getAll();
    result.match(
      (failure) => logger?.error(
        '[GetAllApplicantsUsecase] Failed to get applicants: ${failure.message}',
      ),
      (_) => {},
    );
    return result;
  }
}
