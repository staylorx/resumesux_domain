import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for creating a new jobrec in the database
class CreateJobReqUseCase {
  final JobReqRepository repository;
  final JobReq applicant;
  final JobReq jobReq;
  final Resume resume;
  final CoverLetter? coverLetter;
  final Feedback? feedback;
  final Logger? logger;

  CreateJobReqUseCase({
    required this.repository,
    required this.applicant,
    required this.jobReq,
    required this.resume,
    this.coverLetter,
    this.feedback,
    this.logger,
  });

  Future<Either<Failure, JobReqHandle>> call({
    required String title,
    required String content,
    String? contentType,
  }) async {
    final handle = JobReqHandle.generate();
    final jobReq = JobReq(
      title: title,
      content: content,
      contentType: contentType ?? 'text/markdown',
    );
    await repository.save(handle: handle, jobReq: jobReq);
    return Right(handle); // Return handle for CLI: "Created task [abc123]"
  }
}
