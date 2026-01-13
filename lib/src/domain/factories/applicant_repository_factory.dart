import 'package:resumesux_domain/src/data/data.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Factory for creating ApplicantRepositoryImpl
ApplicantRepository createApplicantRepositoryImpl({
  Logger? logger,
  required ConfigRepository configRepository,
  required ApplicationDatasource applicationDatasource,
  required AiService aiService,
}) =>
    ApplicantRepositoryImpl(
      logger: logger,
      configRepository: configRepository,
      applicationDatasource: applicationDatasource,
      aiService: aiService,
    );