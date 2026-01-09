import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:intl/intl.dart';
import 'package:resume_suckage_domain/resume_suckage_domain.dart';

class ApplicationRepositoryImpl implements ApplicationRepository {
  @override
  Future<Either<Failure, Unit>> saveApplication({
    required String jobReqId,
    required String jobTitle,
    required Resume resume,
    required CoverLetter coverLetter,
    required Feedback feedback,
    required String outputDir,
  }) async {
    try {
      final now = DateTime.now();
      final dateStr = DateFormat('yyyyMMdd').format(now);
      final sanitizedTitle = jobTitle
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(' ', '_');
      final dirName = '$dateStr - $sanitizedTitle';

      final appDir = Directory('$outputDir/$dirName');
      await appDir.create(recursive: true);
      logger.info(
        '[ApplicationRepositoryImpl] Created output directory: ${appDir.path}',
      );

      // Save resume
      final resumeFile = File(
        '${appDir.path}/resume_${sanitizedTitle.toLowerCase()}.md',
      );
      await resumeFile.writeAsString(resume.content);
      logger.info(
        '[ApplicationRepositoryImpl] Saved resume file: ${resumeFile.path} (${resume.content.length} chars)',
      );

      // Save cover letter if provided
      if (coverLetter.content.isNotEmpty) {
        final coverFile = File(
          '${appDir.path}/cover_letter_${sanitizedTitle.toLowerCase()}.md',
        );
        await coverFile.writeAsString(coverLetter.content);
        logger.info(
          '[ApplicationRepositoryImpl] Saved cover letter file: ${coverFile.path} (${coverLetter.content.length} chars)',
        );
      }

      // Save feedback if provided
      if (feedback.content.isNotEmpty) {
        final feedbackFile = File('${appDir.path}/feedback.md');
        await feedbackFile.writeAsString(feedback.content);
        logger.info(
          '[ApplicationRepositoryImpl] Saved feedback file: ${feedbackFile.path} (${feedback.content.length} chars)',
        );
      }

      return Right(unit);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to save application: $e'));
    }
  }
}
