import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

import 'document_repository_impl.dart';

/// Implementation of the ResumeRepository.
class ResumeRepositoryImpl extends DocumentRepositoryImpl
    implements ResumeRepository {
  @override
  Logger get logger => LoggerFactory.create('ResumeRepositoryImpl');

  ResumeRepositoryImpl({required super.fileRepository});

  @override
  Future<Either<Failure, Unit>> saveResume({
    required Resume resume,
    required String outputDir,
    required String jobTitle,
  }) async {
    final filePath = fileRepository.getResumeFilePath(
      appDir: outputDir,
      jobTitle: jobTitle,
    );
    return saveToFile(
      filePath: filePath,
      content: resume.content,
      documentType: 'Resume',
    );
  }
}
