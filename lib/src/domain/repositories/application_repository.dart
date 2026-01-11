import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Repository for managing Application entities.
abstract class ApplicationRepository {
  /// Saves the application metadata to persistent storage (Sembast).
  ///
  /// Parameters:
  /// - [application]: The application to save.
  ///
  /// Returns: [Future<Either<Failure, Unit>>] indicating success or failure.
  Future<Either<Failure, Unit>> saveApplication({
    required Application application,
  });

  /// Saves the application artifacts (resume, cover letter, feedback) to the specified output directory.
  ///
  /// Parameters:
  /// - [application]: The application whose artifacts to save.
  /// - [outputDir]: The base output directory.
  ///
  /// Returns: [Future<Either<Failure, Unit>>] indicating success or failure.
  Future<Either<Failure, Unit>> saveApplicationArtifacts({
    required Application application,
    required String outputDir,
  });
}
