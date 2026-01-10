import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Repository for saving cover letter documents.
abstract class CoverLetterRepository {
  /// Saves a cover letter to a file in the specified output directory.
  ///
  /// Requires jobTitle for file naming.
  Future<Either<Failure, Unit>> saveCoverLetter({
    required CoverLetter coverLetter,
    required String outputDir,
    required String jobTitle,
  });
}
