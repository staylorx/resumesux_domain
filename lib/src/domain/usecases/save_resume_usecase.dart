import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for saving a resume to a file.
class SaveResumeUsecase {
  final Logger logger = LoggerFactory.create('SaveResumeUsecase');
  final FileRepository fileRepository;

  /// Creates a new instance of [SaveResumeUsecase].
  SaveResumeUsecase({required this.fileRepository});

  /// Saves the resume to the specified file path.
  ///
  /// Parameters:
  /// - [resume]: The resume to save.
  /// - [filePath]: The path where to save the resume.
  ///
  /// Returns: [Future<Either<Failure, Unit>>] indicating success or failure.
  Future<Either<Failure, Unit>> call({
    required Resume resume,
    required String filePath,
  }) async {
    logger.info('Saving resume to: $filePath');
    final result = await fileRepository.writeFile(filePath, resume.content);
    if (result.isRight()) {
      logger.info('Resume saved successfully');
    } else {
      logger.severe(
        'Failed to save resume: ${result.getLeft().toNullable()!.message}',
      );
    }
    return result;
  }
}
