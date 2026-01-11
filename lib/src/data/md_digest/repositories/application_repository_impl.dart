import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

// TODO: I don't think anything uses or tests this.

/// Implementation of ApplicationRepository.
class ApplicationRepositoryImpl implements ApplicationRepository {
  final ApplicationSembastDatasource applicationSembastDatasource;
  final FileRepository fileRepository;
  final ResumeRepository resumeRepository;
  final CoverLetterRepository coverLetterRepository;
  final FeedbackRepository feedbackRepository;

  /// Creates a new instance of [ApplicationRepositoryImpl].
  ApplicationRepositoryImpl({
    required this.applicationSembastDatasource,
    required this.fileRepository,
    required this.resumeRepository,
    required this.coverLetterRepository,
    required this.feedbackRepository,
  });

  @override
  Future<Either<Failure, Unit>> saveApplication({
    required Application application,
  }) async {
    final dto = ApplicationDto(
      id: sha256
          .convert(utf8.encode(DateTime.now().toIso8601String()))
          .toString(),
      applicantId: sha256
          .convert(utf8.encode(application.applicant.email))
          .toString(),
      jobReqId: sha256
          .convert(utf8.encode(application.jobReq.content))
          .toString(),
      createdAt: application.createdAt,
      updatedAt: application.updatedAt,
    );
    return applicationSembastDatasource.saveApplication(dto);
  }

  @override
  Future<Either<Failure, Unit>> saveApplicationArtifacts({
    required Application application,
    required String outputDir,
  }) async {
    // Create application directory
    final appDirResult = fileRepository.createApplicationDirectory(
      baseOutputDir: outputDir,
      jobReq: application.jobReq,
    );
    if (appDirResult.isLeft()) {
      return appDirResult.map((_) => unit);
    }
    final appDirPath = appDirResult.getOrElse((_) => '');

    // Save resume
    final resumeFilePath = fileRepository.getResumeFilePath(
      appDir: appDirPath,
      jobTitle: application.jobReq.title,
    );
    final saveResumeResult = await resumeRepository.saveResume(
      resume: application.resume,
      outputDir: resumeFilePath,
      jobTitle: application.jobReq.title,
    );
    if (saveResumeResult.isLeft()) {
      return saveResumeResult;
    }

    // Save cover letter if not empty
    if (application.coverLetter.content.isNotEmpty) {
      final coverFilePath = fileRepository.getCoverLetterFilePath(
        appDir: appDirPath,
        jobTitle: application.jobReq.title,
      );
      final saveCoverResult = await coverLetterRepository.saveCoverLetter(
        coverLetter: application.coverLetter,
        outputDir: coverFilePath,
        jobTitle: application.jobReq.title,
      );
      if (saveCoverResult.isLeft()) {
        return saveCoverResult;
      }
    }

    // Save feedback if not empty
    if (application.feedback.content.isNotEmpty) {
      final feedbackFilePath = fileRepository.getFeedbackFilePath(
        appDir: appDirPath,
      );
      final saveFeedbackResult = await feedbackRepository.saveFeedback(
        feedback: application.feedback,
        outputDir: feedbackFilePath,
      );
      if (saveFeedbackResult.isLeft()) {
        return saveFeedbackResult;
      }
    }

    return Right(unit);
  }
}
