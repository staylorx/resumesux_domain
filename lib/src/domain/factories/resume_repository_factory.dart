import 'package:resumesux_domain/src/data/data.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Factory for creating ResumeRepositoryImpl
ResumeRepository createResumeRepositoryImpl({
  Logger? logger,
  required FileRepository fileRepository,
  required ApplicationDatasource applicationDatasource,
}) => ResumeRepositoryImpl(
  logger: logger,
  fileRepository: fileRepository,
  applicationDatasource: applicationDatasource,
);
