import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Repository for saving feedback documents.
abstract class FeedbackRepository {
  /// Saves a feedback to a file in the specified output directory.
  Future<Either<Failure, Unit>> saveFeedback({
    required Feedback feedback,
    required String outputDir,
  });

  /// Saves the AI response JSON for feedback to the database.
  Future<Either<Failure, Unit>> saveAiResponse({
    required String aiResponseJson,
    required String content,
    required String jobReqId,
  });
}
