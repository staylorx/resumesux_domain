import 'package:resumesux_domain/src/data/data.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Factory for creating JobReqRepositoryImpl
JobReqRepository createJobReqRepositoryImpl({
  Logger? logger,
  required AiService aiService,
  required ApplicationDatasource applicationDatasource,
}) => JobReqRepositoryImpl(
  logger: logger,
  aiService: aiService,
  applicationDatasource: applicationDatasource,
);
