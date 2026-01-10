import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Abstract datasource for job requirement storage operations.
abstract class JobReqDatasource {
  /// Creates a new job requirement.
  Future<Either<Failure, JobReq>> createJobReq({required JobReq jobReq});

  /// Updates an existing job requirement.
  Future<Either<Failure, Unit>> updateJobReq({required JobReq jobReq});
  Future<Either<Failure, Unit>> clearDatabase();
}
