import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Implementation of the FeedbackRepository.
class FeedbackRepositoryImpl extends DocumentRepositoryImpl
    implements FeedbackRepository {
  @override
  Logger get logger => LoggerFactory.create('FeedbackRepositoryImpl');

  final ApplicationSembastDatasource applicationSembastDatasource;

  FeedbackRepositoryImpl({
    required super.fileRepository,
    required this.applicationSembastDatasource,
  });

  @override
  Future<Either<Failure, Unit>> saveFeedback({
    required Feedback feedback,
    required String outputDir,
  }) async {
    final filePath = fileRepository.getFeedbackFilePath(appDir: outputDir);
    return saveToFile(
      filePath: filePath,
      content: feedback.content,
      documentType: 'Feedback',
    );
  }

  @override
  Future<Either<Failure, Unit>> saveAiResponse({
    required String aiResponseJson,
    required String content,
    required String jobReqId,
  }) async {
    final dto = DocumentDto(
      id: 'feedback_$jobReqId',
      content: content,
      aiResponseJson: aiResponseJson,
      documentType: 'feedback',
      jobReqId: jobReqId,
    );
    return applicationSembastDatasource.saveDocument(dto);
  }
}
