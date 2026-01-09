import 'package:fpdart/fpdart.dart';
import 'package:resume_suckage_domain/resume_suckage_domain.dart';

class ApplicantRepositoryImpl implements ApplicantRepository {
  final ConfigRepository configRepository;
  final DigestRepository digestRepository;

  ApplicantRepositoryImpl({
    required this.configRepository,
    required this.digestRepository,
  });

  @override
  Future<Either<Failure, Applicant>> getApplicant({
    required Applicant applicant,
  }) async {
    final digestResult = await digestRepository.getAllDigests();
    if (digestResult.isLeft()) {
      return Left(digestResult.getLeft().toNullable()!);
    }

    final digests = digestResult.getOrElse((failure) => []);
    if (digests.isEmpty) {
      return Left(ValidationFailure(message: 'No digest found'));
    }

    final updatedApplicant = applicant.copyWith(digest: digests.first);
    return Right(updatedApplicant);
  }
}
