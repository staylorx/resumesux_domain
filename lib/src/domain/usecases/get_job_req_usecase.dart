import 'package:fpdart/fpdart.dart';

import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for retrieving a job requirement, with preprocessing if needed.
class GetJobReqUsecase with Loggable {
  final JobReqRepository jobReqRepository;
  final CreateJobReqUsecase createJobReqUsecase;

  /// Creates a new instance of [GetJobReqUsecase].
  GetJobReqUsecase({
    Logger? logger,
    required this.jobReqRepository,
    required this.createJobReqUsecase,
  }) {
    this.logger = logger;
  }

  /// Retrieves the job requirement for the given path.
  ///
  /// If parsing fails, preprocesses the job requirement and retries.
  ///
  /// Parameters:
  /// - [path]: Path to the job requirement file.
  ///
  /// Returns: [Either<Failure, JobReq>] the job requirement or a failure.
  Future<Either<Failure, JobReq>> call({required String path}) async {
    logger?.info('Retrieving job requirement from: $path');

    var jobReqResult = await jobReqRepository.getJobReq(path: path);
    if (jobReqResult.isLeft()) {
      final failure = jobReqResult.getLeft().toNullable()!;
      if (failure is ParsingFailure) {
        logger?.info('Parsing failed, preprocessing job req for: $path');
        final preprocessResult = await createJobReqUsecase(path: path);
        if (preprocessResult.isLeft()) {
          return preprocessResult;
        }
        // Retry getJobReq
        jobReqResult = await jobReqRepository.getJobReq(path: path);
        if (jobReqResult.isLeft()) {
          return jobReqResult;
        }
      } else {
        return jobReqResult;
      }
    }

    final jobReq = (jobReqResult as Right<Failure, JobReq>).value;
    logger?.info('Job requirement retrieved successfully: ${jobReq.title}');
    return Right(jobReq);
  }
}
