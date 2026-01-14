import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

import '../../data.dart';

/// Implementation of ApplicationRepository.
class ApplicationRepositoryImpl with Loggable implements ApplicationRepository {
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
  Future<Either<Failure, Unit>> saveApplicationArtifacts({
    required Application application,
    required Config config,
    required String outputDir,
  }) async {
    // Create application directory
    final appDirResult = fileRepository.createApplicationDirectory(
      baseOutputDir: outputDir,
      jobReq: application.jobReq,
      applicant: application.applicant,
      config: config,
    );
    if (appDirResult.isLeft()) {
      return appDirResult.map((_) => unit);
    }
    final appDirPath = appDirResult.getOrElse((_) => '');

    // Save resume
    final jobReqId =
        'jobreq_${application.jobReq.title.hashCode}_${application.jobReq.content.hashCode}';
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
    if (application.coverLetter!.content.isNotEmpty) {
      final saveCoverResult = await coverLetterRepository.saveCoverLetter(
        coverLetter: application.coverLetter!,
        outputDir: appDirPath,
        jobTitle: application.jobReq.title,
        jobReqId: jobReqId,
      );
      if (saveCoverResult.isLeft()) {
        return saveCoverResult;
      }
    }

    // Save feedback if not empty
    if (application.feedback!.content.isNotEmpty) {
      final saveFeedbackResult = await feedbackRepository.saveFeedback(
        feedback: application.feedback!,
        outputDir: appDirPath,
        jobReqId: jobReqId,
      );
      if (saveFeedbackResult.isLeft()) {
        return saveFeedbackResult;
      }
    }

    return Right(unit);
  }

  @override
  Future<Either<Failure, List<ApplicationWithHandle>>> getAll() async {
    final result = await applicationDatasource.getAllApplications();
    return result.map(
      (dtos) => dtos.map((dto) {
        final handle = ApplicationHandle(dto.id);
        final application = dto.toDomain();
        return ApplicationWithHandle(handle: handle, application: application);
      }).toList(),
    );
  }

  @override
  Future<Either<Failure, Application>> getByHandle({
    required ApplicationHandle handle,
  }) async {
    final result = await applicationDatasource.getApplication(
      handle.toString(),
    );
    result.match(
      (failure) => logger?.warning(
        'Failed to get application by handle: $handle, Error: ${failure.message}',
      ),
      (application) =>
          logger?.info('Successfully retrieved application by handle: $handle'),
    );
    return result.map((dto) => dto.toDomain());
  }

  @override
  Future<Either<Failure, Unit>> save({
    required ApplicationHandle handle,
    required Application application,
  }) {
    final applicantId =
        'applicant_${application.applicant.name.hashCode}_${application.applicant.email.hashCode}';
    final jobReqId =
        'jobreq_${application.jobReq.title.hashCode}_${application.jobReq.content.hashCode}';
    final dto = ApplicationDto(
      id: handle.toString(),
      applicantId: applicantId,
      jobReqId: jobReqId,
      createdAt: application.createdAt,
      updatedAt: application.updatedAt,
    );
    return applicationDatasource.saveApplication(dto);
  }
}
