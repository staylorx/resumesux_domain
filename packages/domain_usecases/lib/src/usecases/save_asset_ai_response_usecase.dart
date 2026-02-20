import 'package:fpdart/fpdart.dart';

import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for saving AI responses for assets to the database.
class SaveAssetAiResponseUsecase with Loggable {
  final AssetRepository assetRepository;

  /// Creates a new instance of [SaveAssetAiResponseUsecase].
  SaveAssetAiResponseUsecase({Logger? logger, required this.assetRepository}) {
    this.logger = logger;
  }

  /// Saves AI responses for assets.
  ///
  /// Parameters:
  /// - [jobReqId]: The job requirement ID.
  ///
  /// Returns: [Either<Failure, Unit>] indicating success or failure.
  Future<Either<Failure, Unit>> call({required String jobReqId}) async {
    logger?.info('Saving AI responses for assets: $jobReqId');

    // Save AI responses for assets
    final assetAiResponseJson = assetRepository.getLastAiResponsesJson();
    if (assetAiResponseJson != null) {
      final saveAssetAiResult = await assetRepository.saveAiResponse(
        aiResponseJson: assetAiResponseJson,
        jobReqId: jobReqId,
      );
      if (saveAssetAiResult.isLeft()) {
        final failure = saveAssetAiResult.getLeft().toNullable()!;
        logger?.warning('Failed to save asset AI response: ${failure.message}');
        // Continue anyway
      }
    }

    logger?.info('AI responses saved successfully for assets');
    return Right(unit);
  }
}
