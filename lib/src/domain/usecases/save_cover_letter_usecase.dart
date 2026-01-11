import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for saving a cover letter to a file.
class SaveCoverLetterUsecase {
  final Logger logger = LoggerFactory.create(name: 'SaveCoverLetterUsecase');
  final FileRepository fileRepository;

  /// Creates a new instance of [SaveCoverLetterUsecase].
  SaveCoverLetterUsecase({required this.fileRepository});

  /// Saves the cover letter to the specified file path.
  ///
  /// Parameters:
  /// - [coverLetter]: The cover letter to save.
  /// - [filePath]: The path where to save the cover letter.
  ///
  /// Returns: [Future<Either<Failure, Unit>>] indicating success or failure.
  Future<Either<Failure, Unit>> call({
    required CoverLetter coverLetter,
    required String filePath,
  }) async {
    logger.info('Saving cover letter to: $filePath');
    final result = await fileRepository.writeFile(
      path: filePath,
      content: coverLetter.content,
    );
    if (result.isRight()) {
      logger.info('Cover letter saved successfully');
    } else {
      logger.severe(
        'Failed to save cover letter: ${result.getLeft().toNullable()!.message}',
      );
    }
    return result;
  }
}
