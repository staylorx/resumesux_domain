import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for creating a new applicant by importing from digest
class CreateApplicantUseCase with Loggable {
  final ApplicantRepository repository;

  CreateApplicantUseCase({required this.repository});

  Future<Either<Failure, ApplicantHandle>> call({
    required Applicant applicant,
    required String digestPath,
  }) async {
    final handle = ApplicantHandle.generate();
    // Import gigs and assets from digest
    final importResult = await repository.importDigest(
      applicant: applicant,
      digestPath: digestPath,
    );
    if (importResult.isLeft()) {
      return Left(importResult.getLeft().toNullable()!);
    }
    final updatedApplicant = importResult.getOrElse((_) => applicant);
    // Save the applicant with gigs and assets
    final saveResult = await repository.save(
      handle: handle,
      applicant: updatedApplicant,
    );
    if (saveResult.isLeft()) {
      return Left(saveResult.getLeft().toNullable()!);
    }
    return Right(handle);
  }
}
