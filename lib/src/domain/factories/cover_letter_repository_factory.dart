import 'package:resumesux_domain/src/data/data.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Factory for creating CoverLetterRepositoryImpl
CoverLetterRepository createCoverLetterRepositoryImpl({
  Logger? logger,
  required FileRepository fileRepository,
  required ApplicationDatasource applicationDatasource,
}) => CoverLetterRepositoryImpl(
  logger: logger,
  fileRepository: fileRepository,
  applicationDatasource: applicationDatasource,
);
