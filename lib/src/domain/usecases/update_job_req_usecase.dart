import 'package:fpdart/fpdart.dart';

import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for updating an existing job requirement.
class UpdateJobReqUsecase with Loggable {
  final JobReqRepository jobReqRepository;

  /// Creates a new instance of [UpdateJobReqUsecase].
  UpdateJobReqUsecase({Logger? logger, required this.jobReqRepository}) {
    this.logger = logger;
  }

  /// Updates the given job requirement.
  ///
  /// Parameters:
  /// - [jobReq]: The job requirement to update.
  ///
  /// Returns: [Either<Failure, Unit>] success or a failure.
  Future<Either<Failure, Unit>> call({required JobReq jobReq}) async {
    logger?.info('[UpdateJobReqUsecase] Updating job req with ${jobReq.title}');

    try {
      return await jobReqRepository.updateJobReq(jobReq: jobReq);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to update job req: $e'));
    }
  }
}
