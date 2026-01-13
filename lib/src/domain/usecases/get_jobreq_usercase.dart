import 'package:fpdart/fpdart.dart';

import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for retrieving job req from database
class GetJobReqUsecase with Loggable {
  final JobReqRepository repository;

  /// gets the instance of [GetJobReqUsecase].
  GetJobReqUsecase({Logger? logger, required this.repository}) {
    this.logger = logger;
  }

  /// Returns: [Either<Failure, JobReq>] containing the enriched applicant or a failure.
  Future<Either<Failure, JobReq>> call(JobReqHandle handle) async {
    logger?.info('[GetJobReqUsecase] getting jobreq information from database');
    final result = await repository.getByHandle(handle: handle);
    result.match(
      (failure) => logger?.error(
        '[GetJobReqUsecase] Failed to get jobreq: ${failure.message}',
      ),
      (_) => {},
    );
    return result;
  }
}
