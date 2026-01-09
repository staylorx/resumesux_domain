import 'package:fpdart/fpdart.dart';
import '../../../../src/core/failure.dart';
import '../entities/applicant.dart';

abstract class ApplicantRepository {
  Future<Either<Failure, Applicant>> getApplicant({
    required Applicant applicant,
  });
}
