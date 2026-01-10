import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Service for managing output directory paths and creation.
/// Provides a centralized way to handle output directory structure and file paths.
class OutputDirectoryService {
  final Logger logger = LoggerFactory.create('OutputDirectoryService');

  /// Creates the application directory path for the given job requirement.
  /// Returns the path to the application directory.
  ///
  /// The directory structure is: baseOutputDir/concernDir/dirName/
  /// where concernDir is the sanitized company name and dirName is timestamp + sanitized title.
  Either<Failure, String> createApplicationDirectory({
    required String baseOutputDir,
    required JobReq jobReq,
  }) {
    try {
      final concernDir = _sanitizeName(jobReq.concern?.name ?? 'unknown');
      final dirName = _createDirName(jobReq.title);
      final appDirPath = '$baseOutputDir/$concernDir/$dirName';

      final appDir = Directory(appDirPath);
      if (!appDir.existsSync()) {
        appDir.createSync(recursive: true);
        logger.info('Created application directory: $appDirPath');
      }

      return Right(appDirPath);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to create application directory: $e'));
    }
  }

  /// Gets the path for the resume file in the application directory.
  String getResumeFilePath(String appDir, String jobTitle) {
    final sanitizedTitle = _sanitizeName(jobTitle);
    return '$appDir/resume_${sanitizedTitle.toLowerCase()}.md';
  }

  /// Gets the path for the cover letter file in the application directory.
  String getCoverLetterFilePath(String appDir, String jobTitle) {
    final sanitizedTitle = _sanitizeName(jobTitle);
    return '$appDir/cover_letter_${sanitizedTitle.toLowerCase()}.md';
  }

  /// Gets the path for the feedback file in the application directory.
  String getFeedbackFilePath(String appDir) {
    return '$appDir/feedback.md';
  }

  /// Gets the path for the AI response file in the application directory.
  String getAiResponseFilePath(String appDir) {
    return '$appDir/ai_response.json';
  }

  /// Validates that the base output directory is accessible.
  Either<Failure, Unit> validateBaseOutputDir(String baseOutputDir) {
    try {
      final dir = Directory(baseOutputDir);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }

      // Try to create a test file to check write permissions
      final testFile = File('$baseOutputDir/.test_write');
      testFile.writeAsStringSync('test');
      testFile.deleteSync();

      return Right(unit);
    } catch (e) {
      return Left(ServiceFailure(message: 'Output directory not accessible: $e'));
    }
  }

  String _sanitizeName(String name) {
    return name
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(' ', '_')
        .toLowerCase();
  }

  String _createDirName(String jobTitle) {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyyMMdd_HHmmss').format(now);
    final sanitizedTitle = _sanitizeName(jobTitle);
    return '$dateStr - $sanitizedTitle';
  }
}