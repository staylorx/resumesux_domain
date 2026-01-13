import 'package:fpdart/fpdart.dart';

import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for saving AI responses for resume to the database.
class SaveResumeAiResponseUsecase with Loggable {
  final ResumeRepository? resumeRepository;

  /// Creates a new instance of [SaveResumeAiResponseUsecase].
  SaveResumeAiResponseUsecase({Logger? logger, this.resumeRepository}) {
    this.logger = logger;
  }

  /// Saves AI response for resume.
  ///
  /// Parameters:
  /// - [jobReqId]: The job requirement ID.
  ///
  /// Returns: [Either<Failure, Unit>] indicating success or failure.
  Future<Either<Failure, Unit>> call({required String jobReqId}) async {
    logger?.info('Saving AI response for resume: $jobReqId');

    // Save AI responses for resume
    final resumeAiResponseJson = resumeRepository?.getLastAiResponseJson();
    if (resumeAiResponseJson != null) {
      final saveResumeAiResult = await resumeRepository!.saveAiResponse(
        aiResponseJson: resumeAiResponseJson,
        jobReqId: jobReqId,
        content: '', // Content is in the JSON
      );
      if (saveResumeAiResult.isLeft()) {
        final failure = saveResumeAiResult.getLeft().toNullable()!;
        logger?.warning(
          'Failed to save resume AI response: ${failure.message}',
        );
        // Continue anyway
      }
    }

    logger?.info('AI response saved successfully for resume');
    return Right(unit);
  }
}
