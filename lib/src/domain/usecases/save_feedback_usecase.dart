import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for saving feedback to a file.
class SaveFeedbackUsecase {
  final Logger logger = LoggerFactory.create('SaveFeedbackUsecase');
  final FileRepository fileRepository;

  /// Creates a new instance of [SaveFeedbackUsecase].
  SaveFeedbackUsecase({required this.fileRepository});

  /// Saves the feedback to the specified file path.
  ///
  /// Parameters:
  /// - [feedback]: The feedback to save.
  /// - [filePath]: The path where to save the feedback.
  ///
  /// Returns: [Future<Either<Failure, Unit>>] indicating success or failure.
  Future<Either<Failure, Unit>> call({
    required Feedback feedback,
    required String filePath,
  }) async {
    logger.info('Saving feedback to: $filePath');
    final result = await fileRepository.writeFile(filePath, feedback.content);
    if (result.isRight()) {
      logger.info('Feedback saved successfully');
    } else {
      logger.severe(
        'Failed to save feedback: ${result.getLeft().toNullable()!.message}',
      );
    }
    return result;
  }
}
