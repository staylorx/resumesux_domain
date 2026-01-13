import 'package:fpdart/fpdart.dart';

import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for saving AI responses for cover letter to the database.
class SaveCoverLetterAiResponseUsecase with Loggable {
  final CoverLetterRepository? coverLetterRepository;

  /// Creates a new instance of [SaveCoverLetterAiResponseUsecase].
  SaveCoverLetterAiResponseUsecase({
    Logger? logger,
    this.coverLetterRepository,
  }) {
    this.logger = logger;
  }

  /// Saves AI response for cover letter.
  ///
  /// Parameters:
  /// - [jobReqId]: The job requirement ID.
  ///
  /// Returns: [Either<Failure, Unit>] indicating success or failure.
  Future<Either<Failure, Unit>> call({required String jobReqId}) async {
    logger?.info('Saving AI response for cover letter: $jobReqId');

    // Save AI responses for cover letter
    final coverLetterAiResponseJson = coverLetterRepository
        ?.getLastAiResponseJson();
    if (coverLetterAiResponseJson != null) {
      final saveCoverLetterAiResult = await coverLetterRepository!
          .saveAiResponse(
            aiResponseJson: coverLetterAiResponseJson,
            jobReqId: jobReqId,
            content: '', // Content is in the JSON
          );
      if (saveCoverLetterAiResult.isLeft()) {
        final failure = saveCoverLetterAiResult.getLeft().toNullable()!;
        logger?.warning(
          'Failed to save cover letter AI response: ${failure.message}',
        );
        // Continue anyway
      }
    }

    logger?.info('AI response saved successfully for cover letter');
    return Right(unit);
  }
}
