import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';
import 'package:resumesux_domain/resumesux_domain.dart';
import 'document_repository_impl.dart';

/// Implementation of the CoverLetterRepository.
class CoverLetterRepositoryImpl extends DocumentRepositoryImpl
    implements CoverLetterRepository {
  @override
  Logger get logger => LoggerFactory.create('CoverLetterRepositoryImpl');

  CoverLetterRepositoryImpl({required super.outputDirectoryService});

  @override
  Future<Either<Failure, Unit>> saveCoverLetter({
    required CoverLetter coverLetter,
    required String outputDir,
    required String jobTitle,
  }) async {
    final filePath = outputDirectoryService.getCoverLetterFilePath(
      appDir: outputDir,
      jobTitle: jobTitle,
    );
    return saveToFile(
      filePath: filePath,
      content: coverLetter.content,
      documentType: 'CoverLetter',
    );
  }
}
