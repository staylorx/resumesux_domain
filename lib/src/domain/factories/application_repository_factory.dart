import 'package:resumesux_domain/src/data/data.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Factory for creating ApplicationRepositoryImpl
ApplicationRepository createApplicationRepositoryImpl({
  required ApplicationDatasource applicationDatasource,
  required FileRepository fileRepository,
  required ResumeRepository resumeRepository,
  required CoverLetterRepository coverLetterRepository,
  required FeedbackRepository feedbackRepository,
}) =>
    ApplicationRepositoryImpl(
      applicationDatasource: applicationDatasource,
      fileRepository: fileRepository,
      resumeRepository: resumeRepository,
      coverLetterRepository: coverLetterRepository,
      feedbackRepository: feedbackRepository,
    );