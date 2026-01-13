import 'package:resumesux_domain/src/data/data.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Factory for creating GigRepositoryImpl
GigRepository createGigRepositoryImpl({
  Logger? logger,
  required String digestPath,
  required AiService aiService,
  required ApplicationDatasource applicationDatasource,
}) => GigRepositoryImpl(
  logger: logger,
  digestPath: digestPath,
  aiService: aiService,
  applicationDatasource: applicationDatasource,
);
