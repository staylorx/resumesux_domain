import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Repository for saving resume documents.
abstract class ResumeRepository implements DocRepository {
  /// Saves a resume to a file in the specified output directory.
  ///
  /// Requires jobTitle for file naming.
  Future<Either<Failure, Unit>> saveResume({
    required Resume resume,
    required String outputDir,
    required String jobTitle,
  });

  /// Saves the AI response JSON for a resume to the database.
  @override
  Future<Either<Failure, Unit>> saveAiResponse({
    required String aiResponseJson,
    required String jobReqId,
    String? content,
  });
}
