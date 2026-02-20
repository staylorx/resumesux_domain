import 'package:fpdart/fpdart.dart';

import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for saving AI responses for feedback to the database.
class SaveFeedbackAiResponseUsecase with Loggable {
  final FeedbackRepository? feedbackRepository;

  /// Creates a new instance of [SaveFeedbackAiResponseUsecase].
  SaveFeedbackAiResponseUsecase({Logger? logger, this.feedbackRepository}) {
    this.logger = logger;
  }

  /// Saves AI response for feedback.
  ///
  /// Parameters:
  /// - [jobReqId]: The job requirement ID.
  ///
  /// Returns: [Either<Failure, Unit>] indicating success or failure.
  Future<Either<Failure, Unit>> call({required String jobReqId}) async {
    logger?.info('Saving AI response for feedback: $jobReqId');

    // Save AI responses for feedback
    final feedbackAiResponseJson = feedbackRepository?.getLastAiResponseJson();
    if (feedbackAiResponseJson != null) {
      final saveFeedbackAiResult = await feedbackRepository!.saveAiResponse(
        aiResponseJson: feedbackAiResponseJson,
        jobReqId: jobReqId,
        content: '', // Content is in the JSON
      );
      if (saveFeedbackAiResult.isLeft()) {
        final failure = saveFeedbackAiResult.getLeft().toNullable()!;
        logger?.warning(
          'Failed to save feedback AI response: ${failure.message}',
        );
        // Continue anyway
      }
    }

    logger?.info('AI response saved successfully for feedback');
    return Right(unit);
  }
}
