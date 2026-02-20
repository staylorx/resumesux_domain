import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for creating a new application
class CreateApplicationUseCase {
  final ApplicationRepository repository;
  final Applicant applicant;
  final JobReq jobReq;
  final Resume resume;
  final CoverLetter? coverLetter;
  final Feedback? feedback;

  CreateApplicationUseCase({
    required this.repository,
    required this.applicant,
    required this.jobReq,
    required this.resume,
    this.coverLetter,
    this.feedback,
  });

  Future<Either<Failure, ApplicationHandle>> call({
    required String outputDir,
  }) async {
    final handle = ApplicationHandle.generate();
    final newApplication = Application(
      applicant: applicant,
      jobReq: jobReq,
      resume: resume,
      coverLetter: coverLetter,
      feedback: feedback,
    );
    await repository.save(handle: handle, application: newApplication);
    return Right(handle); // Return handle for CLI: "Created task [abc123]"
  }
}
