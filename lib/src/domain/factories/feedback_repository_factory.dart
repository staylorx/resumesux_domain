import 'package:resumesux_domain/src/data/data.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Factory for creating FeedbackRepositoryImpl
FeedbackRepository createFeedbackRepositoryImpl({
  Logger? logger,
  required FileRepository fileRepository,
  required ApplicationDatasource applicationDatasource,
}) =>
    FeedbackRepositoryImpl(
      logger: logger,
      fileRepository: fileRepository,
      applicationDatasource: applicationDatasource,
    );