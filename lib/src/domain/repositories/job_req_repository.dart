import 'package:fpdart/fpdart.dart';
import 'package:resume_suckage_domain/resume_suckage_domain.dart';

abstract class JobReqRepository {
  Future<Either<Failure, JobReq>> getJobReq({required String path});
  // TODO: for good cleanarch and DI, should this have the jobreq as a parameter?
  Future<Either<Failure, Unit>> markAsProcessed({required String id});
  Future<Either<Failure, Unit>> updateFrontmatter({
    required String path,
    required JobReq jobReq,
  });
}
