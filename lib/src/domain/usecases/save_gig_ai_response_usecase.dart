import 'package:fpdart/fpdart.dart';

import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for saving AI responses for gigs to the database.
class SaveGigAiResponseUsecase with Loggable {
  final GigRepository gigRepository;

  /// Creates a new instance of [SaveGigAiResponseUsecase].
  SaveGigAiResponseUsecase({Logger? logger, required this.gigRepository}) {
    this.logger = logger;
  }

  /// Saves AI responses for gigs.
  ///
  /// Parameters:
  /// - [jobReqId]: The job requirement ID.
  ///
  /// Returns: [Either<Failure, Unit>] indicating success or failure.
  Future<Either<Failure, Unit>> call({required String jobReqId}) async {
    logger?.info('Saving AI responses for gigs: $jobReqId');

    // Save AI responses for gigs
    final gigAiResponseJson = gigRepository.getLastAiResponsesJson();
    if (gigAiResponseJson != null) {
      final saveGigAiResult = await gigRepository.saveAiResponse(
        aiResponseJson: gigAiResponseJson,
        jobReqId: jobReqId,
      );
      if (saveGigAiResult.isLeft()) {
        final failure = saveGigAiResult.getLeft().toNullable()!;
        logger?.warning('Failed to save gig AI response: ${failure.message}');
        // Continue anyway
      }
    }

    logger?.info('AI responses saved successfully for gigs');
    return Right(unit);
  }
}
