import 'package:fpdart/fpdart.dart';
import 'package:resume_suckage_domain/resume_suckage_domain.dart';

/// Repository for job requirement-related operations.
abstract class JobReqRepository {
  /// Retrieves a job requirement from the given path.
  Future<Either<Failure, JobReq>> getJobReq({required String path});

  /// Marks the job requirement as processed.
  Future<Either<Failure, Unit>> markAsProcessed({required String path});

  /// Updates the frontmatter of the job requirement file.
  Future<Either<Failure, Unit>> updateFrontmatter({
    required String path,
    required JobReq jobReq,
  });
}
