import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

import 'document_repository_impl.dart';

/// Implementation of the FeedbackRepository.
class FeedbackRepositoryImpl extends DocumentRepositoryImpl
    implements FeedbackRepository {
  @override
  Logger get logger => LoggerFactory.create('FeedbackRepositoryImpl');

  FeedbackRepositoryImpl({required super.outputDirectoryService});

  @override
  Future<Either<Failure, Unit>> saveFeedback({
    required Feedback feedback,
    required String outputDir,
  }) async {
    final filePath = outputDirectoryService.getFeedbackFilePath(
      appDir: outputDir,
    );
    return saveToFile(
      filePath: filePath,
      content: feedback.content,
      documentType: 'Feedback',
    );
  }
}
