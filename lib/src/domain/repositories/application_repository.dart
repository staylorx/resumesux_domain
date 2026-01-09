import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Repository for application-related operations.
abstract class ApplicationRepository {
  /// Saves the application files.
  Future<Either<Failure, Unit>> saveApplication({
    required String jobReqId,
    required String jobTitle,
    required Resume resume,
    required CoverLetter coverLetter,
    required Feedback feedback,
    required String outputDir,
    required Concern concern,
  });
}
