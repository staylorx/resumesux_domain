import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

// Projection for CLI output
class JobReqWithHandle {
  final JobReqHandle handle;
  final JobReq jobReq;
  JobReqWithHandle({required this.handle, required this.jobReq});
}

/// Repository for job requirement-related operations.
abstract class JobReqRepository implements DocRepository {
  /// Creates a new job requirement.
  Future<Either<Failure, JobReq>> createJobReq({required JobReq jobReq});

  /// Retrieves a job requirement from the given path.
  Future<Either<Failure, JobReq>> getJobReq({required String path});

  /// Updates an existing job requirement.
  Future<Either<Failure, Unit>> updateJobReq({required JobReq jobReq});

  /// Retrieves the last AI response as JSON string.
  @override
  String? getLastAiResponseJson();

  /// Saves the AI response JSON for a job requirement to the database.
  @override
  Future<Either<Failure, Unit>> saveAiResponse({
    required String aiResponseJson,
    required String jobReqId,
    String? content,
  });

  Future<Either<Failure, Unit>> save({
    required JobReqHandle handle,
    required JobReq jobReq,
  });
  Future<Either<Failure, JobReq>> getByHandle({required JobReqHandle handle});
  Future<Either<Failure, List<JobReqWithHandle>>> getAll(); // For listing
  Future<Either<Failure, Unit>> remove({required JobReqHandle handle});
}
