import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for saving AI responses to the database.
class SaveAiResponsesUsecase {
  final Logger logger = LoggerFactory.create(name: 'SaveAiResponsesUsecase');
  final JobReqRepository jobReqRepository;
  final GigRepository gigRepository;
  final AssetRepository assetRepository;
  final ResumeRepository? resumeRepository;
  final CoverLetterRepository? coverLetterRepository;
  final FeedbackRepository? feedbackRepository;

  /// Creates a new instance of [SaveAiResponsesUsecase].
  SaveAiResponsesUsecase({
    required this.jobReqRepository,
    required this.gigRepository,
    required this.assetRepository,
    this.resumeRepository,
    this.coverLetterRepository,
    this.feedbackRepository,
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
    final gigAiResponseJson = gigRepository.getLastAiResponsesJson();
    if (gigAiResponseJson != null) {
      final saveGigAiResult = await gigRepository.saveAiResponse(
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
    final assetAiResponseJson = assetRepository.getLastAiResponsesJson();
    if (assetAiResponseJson != null) {
      final saveAssetAiResult = await assetRepository.saveAiResponse(
        aiResponseJson: assetAiResponseJson,
        jobReqId: jobReqId,
      );
      if (saveAssetAiResult.isLeft()) {
        final failure = saveAssetAiResult.getLeft().toNullable()!;
        logger.warning('Failed to save asset AI response: ${failure.message}');
        // Continue anyway
      }
    }

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
        logger.warning('Failed to save resume AI response: ${failure.message}');
        // Continue anyway
      }
    }

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
        logger.warning(
          'Failed to save cover letter AI response: ${failure.message}',
        );
        // Continue anyway
      }
    }

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
        logger.warning(
          'Failed to save feedback AI response: ${failure.message}',
        );
        // Continue anyway
      }
    }

    logger.info('AI responses saved successfully');
    return Right(unit);
  }
}
