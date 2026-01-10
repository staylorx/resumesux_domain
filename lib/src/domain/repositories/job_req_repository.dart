import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Repository for job requirement-related operations.
abstract class JobReqRepository {
  /// Creates a new job requirement.
  Future<Either<Failure, JobReq>> createJobReq({required JobReq jobReq});

  /// Retrieves a job requirement from the given path.
  Future<Either<Failure, JobReq>> getJobReq({required String path});

  /// Updates an existing job requirement.
  Future<Either<Failure, Unit>> updateJobReq({required JobReq jobReq});
}
