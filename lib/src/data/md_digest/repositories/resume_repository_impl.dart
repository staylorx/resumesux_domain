import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Implementation of the ResumeRepository.
class ResumeRepositoryImpl extends DocumentRepositoryImpl
    implements ResumeRepository {
  @override
  Logger get logger => LoggerFactory.create('ResumeRepositoryImpl');

  final DocumentSembastDatasource documentSembastDatasource;

  ResumeRepositoryImpl({
    required super.fileRepository,
    required this.documentSembastDatasource,
  });

  @override
  Future<Either<Failure, Unit>> saveResume({
    required Resume resume,
    required String outputDir,
    required String jobTitle,
  }) async {
    final filePath = fileRepository.getResumeFilePath(
      appDir: outputDir,
      jobTitle: jobTitle,
    );
    return saveToFile(
      filePath: filePath,
      content: resume.content,
      documentType: 'Resume',
    );
  }

  @override
  Future<Either<Failure, Unit>> saveAiResponse({
    required String aiResponseJson,
    String? content,
    required String jobReqId,
  }) async {
    final dto = DocumentDto(
      id: 'resume_$jobReqId', // Unique ID based on job req
      content: content!,
      aiResponseJson: aiResponseJson,
      documentType: 'resume',
      jobReqId: jobReqId,
    );
    return documentSembastDatasource.saveDocument(dto);
  }
}
