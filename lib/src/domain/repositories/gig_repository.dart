import 'package:fpdart/fpdart.dart';
import 'package:resume_suckage_domain/resume_suckage_domain.dart';

abstract class GigRepository {
  Future<Either<Failure, List<Gig>>> getAllGigs();
}
