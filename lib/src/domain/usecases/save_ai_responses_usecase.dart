import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for saving AI responses to the database.
class SaveAiResponsesUsecase {
  final Logger logger = LoggerFactory.create('SaveAiResponsesUsecase');
  final JobReqRepository jobReqRepository;
  final DigestRepository digestRepository;

  /// Creates a new instance of [SaveAiResponsesUsecase].
  SaveAiResponsesUsecase({
    required this.jobReqRepository,
    required this.digestRepository,
  });

  /// Saves AI responses for the job requirement, gigs, and assets.
  ///
  /// Parameters:
  /// - [jobReqId]: The job requirement ID.
  ///
  /// Returns: [Either<Failure, Unit>] indicating success or failure.
  Future<Either<Failure, Unit>> call({required String jobReqId}) async {
    logger.info('Saving AI responses for job requirement: $jobReqId');

    // Save AI response for job req
    final aiResponseJson = jobReqRepository.getLastAiResponseJson();
    if (aiResponseJson != null) {
      final saveAiResult = await jobReqRepository.saveAiResponse(
        aiResponseJson: aiResponseJson,
        jobReqId: jobReqId,
      );
      if (saveAiResult.isLeft()) {
        final failure = saveAiResult.getLeft().toNullable()!;
        logger.warning('Failed to save AI response: ${failure.message}');
        // Continue anyway, as it's not critical
      }
    }

    // Save AI responses for gigs
    final gigAiResponseJson = digestRepository.gigRepository
        .getLastAiResponsesJson();
    if (gigAiResponseJson != null) {
      final saveGigAiResult = await digestRepository.saveGigAiResponse(
        aiResponseJson: gigAiResponseJson,
        jobReqId: jobReqId,
      );
      if (saveGigAiResult.isLeft()) {
        final failure = saveGigAiResult.getLeft().toNullable()!;
        logger.warning('Failed to save gig AI response: ${failure.message}');
        // Continue anyway
      }
    }

    // Save AI responses for assets
    final assetAiResponseJson = digestRepository.assetRepository
        .getLastAiResponsesJson();
    if (assetAiResponseJson != null) {
      final saveAssetAiResult = await digestRepository.saveAssetAiResponse(
        aiResponseJson: assetAiResponseJson,
        jobReqId: jobReqId,
      );
      if (saveAssetAiResult.isLeft()) {
        final failure = saveAssetAiResult.getLeft().toNullable()!;
        logger.warning('Failed to save asset AI response: ${failure.message}');
        // Continue anyway
      }
    }

    logger.info('AI responses saved successfully');
    return Right(unit);
  }
}
