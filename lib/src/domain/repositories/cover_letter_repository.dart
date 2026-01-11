import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Repository for saving cover letter documents.
abstract class CoverLetterRepository implements DocRepository {
  /// Saves a cover letter to a file in the specified output directory.
  ///
  /// Requires jobTitle for file naming.
  Future<Either<Failure, Unit>> saveCoverLetter({
    required CoverLetter coverLetter,
    required String outputDir,
    required String jobTitle,
  });

  /// Saves the AI response JSON for a cover letter to the database.
  @override
  Future<Either<Failure, Unit>> saveAiResponse({
    required String aiResponseJson,
    required String jobReqId,
    String? content,
  });
}
