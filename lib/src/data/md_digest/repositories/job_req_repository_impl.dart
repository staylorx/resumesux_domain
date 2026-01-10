import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Implementation of the JobReqRepository.
class JobReqRepositoryImpl implements JobReqRepository {
  final JobReqDatasource jobReqDatasource;
  final FileJobReqDatasource fileJobReqDatasource;

  JobReqRepositoryImpl({
    required this.jobReqDatasource,
    required this.fileJobReqDatasource,
  });
  @override
  Future<Either<Failure, JobReq>> createJobReq({required JobReq jobReq}) async {
    return await jobReqDatasource.createJobReq(jobReq: jobReq);
  }

  @override
  /// Updates an existing job requirement.
  Future<Either<Failure, Unit>> updateJobReq({required JobReq jobReq}) async {
    return await jobReqDatasource.updateJobReq(jobReq: jobReq);
  }

  @override
  /// Retrieves a job requirement from the given path.
  Future<Either<Failure, JobReq>> getJobReq({required String path}) async {
    final result = await fileJobReqDatasource.getJobReq(path: path);
    if (result.isRight()) {
      final jobReq = result.getOrElse((_) => throw '');
      // Save to database for persistence
      await jobReqDatasource.updateJobReq(jobReq: jobReq);
    }
    return result;
  }
}
