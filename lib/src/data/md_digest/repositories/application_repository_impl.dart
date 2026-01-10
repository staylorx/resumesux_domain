import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Implementation of the ApplicationRepository.
class ApplicationRepositoryImpl implements ApplicationRepository {
  final Logger logger = LoggerFactory.create('ApplicationRepositoryImpl');
  final OutputDirectoryService outputDirectoryService;

  ApplicationRepositoryImpl({required this.outputDirectoryService});

  @override
  /// Saves the application files to the application directory.
  Future<Either<Failure, Unit>> saveApplication({
    required String jobReqId,
    required String jobTitle,
    required Resume resume,
    required CoverLetter coverLetter,
    required Feedback feedback,
    required String appDirPath,
  }) async {
    try {
      logger.info(
        '[ApplicationRepositoryImpl] Saving to application directory: $appDirPath',
      );

      // Save resume
      final resumeFilePath = outputDirectoryService.getResumeFilePath(
        appDir: appDirPath,
        jobTitle: jobTitle,
      );
      final resumeFile = File(resumeFilePath);
      await resumeFile.writeAsString(resume.content);
      logger.info(
        '[ApplicationRepositoryImpl] Saved resume file: $resumeFilePath (${resume.content.length} chars)',
      );

      // Save cover letter if provided
      if (coverLetter.content.isNotEmpty) {
        final coverFilePath = outputDirectoryService.getCoverLetterFilePath(
          appDir: appDirPath,
          jobTitle: jobTitle,
        );
        final coverFile = File(coverFilePath);
        await coverFile.writeAsString(coverLetter.content);
        logger.info(
          '[ApplicationRepositoryImpl] Saved cover letter file: $coverFilePath (${coverLetter.content.length} chars)',
        );
      }

      // Save feedback if provided
      if (feedback.content.isNotEmpty) {
        final feedbackFilePath = outputDirectoryService.getFeedbackFilePath(
          appDir: appDirPath,
        );
        final feedbackFile = File(feedbackFilePath);
        await feedbackFile.writeAsString(feedback.content);
        logger.info(
          '[ApplicationRepositoryImpl] Saved feedback file: $feedbackFilePath (${feedback.content.length} chars)',
        );
      }

      return Right(unit);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to save application: $e'));
    }
  }
}
