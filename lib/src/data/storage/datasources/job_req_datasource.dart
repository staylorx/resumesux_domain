import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Abstract datasource for job requirement storage operations.
abstract class JobReqDatasource {
  /// Saves a preprocessed job requirement.
  Future<Either<Failure, Unit>> savePreprocessedJobReq({
    required JobReq jobReq,
  });
}