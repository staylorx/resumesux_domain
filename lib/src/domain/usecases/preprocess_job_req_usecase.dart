import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';
import 'package:resume_suckage_domain/resume_suckage_domain.dart';

/// Use case for preprocessing job requirements.
class PreprocessJobReqUsecase {
  final Logger logger = LoggerFactory.create('PreprocessJobReqUsecase');

  /// Generate job req frontmatter use case.
  final GenerateJobReqFrontmatterUsecase generateJobReqFrontmatterUsecase;

  /// Creates a new preprocess job req use case.
  PreprocessJobReqUsecase({required this.generateJobReqFrontmatterUsecase});

  /// Executes the preprocess job req use case.
  Future<Either<Failure, Map<String, dynamic>>> call({
    required String jobReqPath,
  }) async {
    logger.info(
      '[PreprocessJobReqUsecase] Preprocessing job req at $jobReqPath',
    );

    final result = await generateJobReqFrontmatterUsecase.call(
      path: jobReqPath,
    );

    return result.fold(
      (failure) {
        logger.severe(
          '[PreprocessJobReqUsecase] Failed to preprocess: ${failure.message}',
        );
        return Left(failure);
      },
      (jobReq) {
        logger.info(
          '[PreprocessJobReqUsecase] Successfully preprocessed job req: ${jobReq.title}',
        );
        return Right({
          'status': 'success',
          'message': 'Job requirements preprocessed successfully!',
          'title': jobReq.title,
        });
      },
    );
  }
}
