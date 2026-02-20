import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Projection for CLI output
class ApplicationWithHandle {
  final ApplicationHandle handle;
  final Application application;
  ApplicationWithHandle({required this.handle, required this.application});
}

/// Repository for managing Application entities.
abstract class ApplicationRepository {
  /// Saves the application artifacts (resume, cover letter, feedback) to the specified output directory.
  Future<Either<Failure, Unit>> saveApplicationArtifacts({
    required Application application,
    required Config config,
    required String outputDir,
  });

  Future<Either<Failure, Unit>> save({
    required ApplicationHandle handle,
    required Application application,
  });
  Future<Either<Failure, Application>> getByHandle({
    required ApplicationHandle handle,
  });
  Future<Either<Failure, List<ApplicationWithHandle>>> getAll(); // For listing
}
