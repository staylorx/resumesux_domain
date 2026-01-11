import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Repository for file operations.
/// Provides abstraction for reading, writing, and managing files and directories.
abstract class FileRepository {
  /// Reads the content of a file at the given path.
  /// Returns the file content or a failure.
  Either<Failure, String> readFile(String path);

  /// Writes content to a file at the given path.
  /// Returns success or a failure.
  Future<Either<Failure, Unit>> writeFile(String path, String content);

  /// Creates a directory at the given path if it doesn't exist.
  /// Returns success or a failure.
  Either<Failure, Unit> createDirectory(String path);

  /// Validates that the directory is accessible for writing.
  /// Returns success or a failure.
  Either<Failure, Unit> validateDirectory(String path);

  /// Creates the application directory path for the given job requirement.
  /// Returns the path to the application directory.
  ///
  /// The directory structure is: baseOutputDir/concernDir/dirName/
  /// where concernDir is the sanitized company name and dirName is timestamp + sanitized title.
  Either<Failure, String> createApplicationDirectory({
    required String baseOutputDir,
    required JobReq jobReq,
  });

  /// Gets the path for the resume file in the application directory.
  String getResumeFilePath({required String appDir, required String jobTitle});

  /// Gets the path for the cover letter file in the application directory.
  String getCoverLetterFilePath({
    required String appDir,
    required String jobTitle,
  });

  /// Gets the path for the feedback file in the application directory.
  String getFeedbackFilePath({required String appDir});

  /// Gets the path for the AI response file in the application directory.
  /// The file name includes the type to distinguish between different AI calls.
  String getAiResponseFilePath({required String appDir, required String type});

  /// Validates that all Markdown files in the directory are valid Markdown.
  Future<Either<Failure, Unit>> validateMarkdownFiles({
    required String directory,
    required String fileExtension,
  });
}
