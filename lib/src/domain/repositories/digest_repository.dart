import 'package:fpdart/fpdart.dart';
import 'package:resume_suckage_domain/resume_suckage_domain.dart';

abstract class DigestRepository {
  Future<Either<Failure, List<Digest>>> getAllDigests();
}
