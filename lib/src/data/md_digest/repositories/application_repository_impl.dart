import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

import '../../data.dart';

/// Implementation of ApplicationRepository.
class ApplicationRepositoryImpl implements ApplicationRepository {
  final ApplicationDatasource applicationDatasource;
  final FileRepository fileRepository;
  final ResumeRepository resumeRepository;
  final CoverLetterRepository coverLetterRepository;
  final FeedbackRepository feedbackRepository;
  final ApplicantRepository? applicantRepository;

  /// Creates a new instance of [ApplicationRepositoryImpl].
  ApplicationRepositoryImpl({
    required this.applicationDatasource,
    required this.fileRepository,
    required this.resumeRepository,
    required this.coverLetterRepository,
    required this.feedbackRepository,
    this.applicantRepository,
  });

  @override
  Future<Either<Failure, Unit>> saveApplication({
    required Application application,
  }) async {
    // Save applicant if repository available
    if (applicantRepository != null) {
      final saveApplicantResult = await applicantRepository!.saveApplicant(
        applicant: application.applicant,
      );
      if (saveApplicantResult.isLeft()) {
        return saveApplicantResult;
      }
    }

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
    return applicationDatasource.saveApplication(dto);
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
    final jobReqId = application.jobReq.hashCode.toString();
    final saveResumeResult = await resumeRepository.saveResume(
      resume: application.resume,
      outputDir: appDirPath,
      jobTitle: application.jobReq.title,
      jobReqId: jobReqId,
    );
    if (saveResumeResult.isLeft()) {
      return saveResumeResult;
    }

    // Save cover letter if not empty
    if (application.coverLetter.content.isNotEmpty) {
      final saveCoverResult = await coverLetterRepository.saveCoverLetter(
        coverLetter: application.coverLetter,
        outputDir: appDirPath,
        jobTitle: application.jobReq.title,
        jobReqId: jobReqId,
      );
      if (saveCoverResult.isLeft()) {
        return saveCoverResult;
      }
    }

    // Save feedback if not empty
    if (application.feedback.content.isNotEmpty) {
      final saveFeedbackResult = await feedbackRepository.saveFeedback(
        feedback: application.feedback,
        outputDir: appDirPath,
        jobReqId: jobReqId,
      );
      if (saveFeedbackResult.isLeft()) {
        return saveFeedbackResult;
      }
    }

    return Right(unit);
  }
}
