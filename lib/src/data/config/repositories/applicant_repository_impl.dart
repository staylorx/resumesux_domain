import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Implementation of the ApplicantRepository.
class ApplicantRepositoryImpl implements ApplicantRepository {
  final ConfigRepository configRepository;
  final DigestRepository digestRepository;

  ApplicantRepositoryImpl({
    required this.configRepository,
    required this.digestRepository,
  });

  @override
  /// Retrieves the applicant with updated digest information.
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
