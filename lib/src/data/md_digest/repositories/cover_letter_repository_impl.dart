import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Implementation of the CoverLetterRepository.
class CoverLetterRepositoryImpl extends DocumentRepositoryImpl
    implements CoverLetterRepository {
  @override
  Logger get logger => LoggerFactory.create('CoverLetterRepositoryImpl');

  final ApplicationSembastDatasource applicationSembastDatasource;

  CoverLetterRepositoryImpl({
    required super.fileRepository,
    required this.applicationSembastDatasource,
  });

  @override
  Future<Either<Failure, Unit>> saveCoverLetter({
    required CoverLetter coverLetter,
    required String outputDir,
    required String jobTitle,
  }) async {
    final filePath = fileRepository.getCoverLetterFilePath(
      appDir: outputDir,
      jobTitle: jobTitle,
    );
    return saveToFile(
      filePath: filePath,
      content: coverLetter.content,
      documentType: 'CoverLetter',
    );
  }

  @override
  Future<Either<Failure, Unit>> saveAiResponse({
    required String aiResponseJson,
    required String jobReqId,
    String? content,
  }) async {
    final dto = DocumentDto(
      id: 'cover_letter_$jobReqId',
      content: content!,
      aiResponseJson: aiResponseJson,
      documentType: 'cover_letter',
      jobReqId: jobReqId,
    );
    return applicationSembastDatasource.saveDocument(dto);
  }
}
