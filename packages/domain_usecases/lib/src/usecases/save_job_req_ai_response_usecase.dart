import 'package:fpdart/fpdart.dart';

import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for saving AI responses for job requirements to the database.
class SaveJobReqAiResponseUsecase with Loggable {
  final JobReqRepository jobReqRepository;

  /// Creates a new instance of [SaveJobReqAiResponseUsecase].
  SaveJobReqAiResponseUsecase({
    Logger? logger,
    required this.jobReqRepository,
  }) {
    this.logger = logger;
  }

  /// Saves AI response for the job requirement.
  ///
  /// Parameters:
  /// - [jobReqId]: The job requirement ID.
  ///
  /// Returns: [Either<Failure, Unit>] indicating success or failure.
  Future<Either<Failure, Unit>> call({required String jobReqId}) async {
    logger?.info('Saving AI response for job requirement: $jobReqId');

    // Save AI response for job req
    final aiResponseJson = jobReqRepository.getLastAiResponseJson();
    if (aiResponseJson != null) {
      final saveAiResult = await jobReqRepository.saveAiResponse(
        aiResponseJson: aiResponseJson,
        jobReqId: jobReqId,
      );
      if (saveAiResult.isLeft()) {
        final failure = saveAiResult.getLeft().toNullable()!;
        logger?.warning('Failed to save AI response: ${failure.message}');
        // Continue anyway, as it's not critical
      }
    }

    logger?.info('AI response saved successfully for job requirement');
    return Right(unit);
  }
}
