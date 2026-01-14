import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:intl/intl.dart';
import 'package:markdown/markdown.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Implementation of FileRepository using dart:io.
/// This belongs in the adapters layer as it deals with framework concerns.
class FileRepositoryImpl with Loggable implements FileRepository {
  FileRepositoryImpl({Logger? logger}) {
    this.logger = logger;
  }

  @override
  Either<Failure, String> readFile({required String path}) {
    try {
      final file = File(path);
      if (!file.existsSync()) {
        return Left(NotFoundFailure(message: 'File not found: $path'));
      }
      final content = file.readAsStringSync();
      return Right(content);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to read file: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> writeFile({
    required String path,
    required String content,
  }) async {
    try {
      final file = File(path);
      await file.writeAsString(content);
      logger?.info('Wrote file: $path (${content.length} chars)');
      return Right(unit);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to write file: $e'));
    }
  }

  @override
  Either<Failure, Unit> createDirectory({required String path}) {
    try {
      final dir = Directory(path);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
        logger?.info('Created directory: $path');
      }
      return Right(unit);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to create directory: $e'));
    }
  }

  @override
  Either<Failure, Unit> validateDirectory({required String path}) {
    try {
      final dir = Directory(path);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }

      // Try to create a test file to check write permissions
      final testFile = File('$path/.test_write');
      testFile.writeAsStringSync('test');
      testFile.deleteSync();

      return Right(unit);
    } catch (e) {
      return Left(
        ServiceFailure(message: 'Output directory not accessible: $e'),
      );
    }
  }

  @override
  Either<Failure, String> createApplicationDirectory({
    required String baseOutputDir,
    required JobReq jobReq,
    required Applicant applicant,
    required Config config,
  }) {
    try {
      // Use folderOrder from config if provided, otherwise default to current behavior
      final folderOrder =
          config.folderOrder ??
          [
            FolderField.concern,
            FolderField.applicant_name,
            FolderField.jobreq_title,
          ];

      final pathSegments = <String>[];
      for (final field in folderOrder) {
        final segment = _getFieldValue(field, jobReq, applicant);
        if (segment != null) {
          pathSegments.add(_sanitizeName(name: segment));
        }
      }

      // Special handling: if the last two fields are applicant_name and jobreq_title, combine them with ' - '
      if (folderOrder.length >= 2 &&
          folderOrder[folderOrder.length - 2] == FolderField.applicant_name &&
          folderOrder.last == FolderField.jobreq_title) {
        final applicantSegment = pathSegments.removeLast();
        final jobTitleSegment = pathSegments.removeLast();
        pathSegments.add('$applicantSegment - $jobTitleSegment');
      }

      final appDirPath = '$baseOutputDir/${pathSegments.join('/')}';

      final appDir = Directory(appDirPath);
      if (!appDir.existsSync()) {
        appDir.createSync(recursive: true);
        logger?.info('Created application directory: $appDirPath');
      } else {
        logger?.debug('Reusing existing application directory: $appDirPath');
      }

      return Right(appDirPath);
    } catch (e) {
      return Left(
        ServiceFailure(message: 'Failed to create application directory: $e'),
      );
    }
  }

  @override
  String getResumeFilePath({required String appDir, required String jobTitle}) {
    final sanitizedTitle = _sanitizeName(name: jobTitle);
    return '$appDir/resume_${sanitizedTitle.toLowerCase()}${_getTimestamp()}.md';
  }

  @override
  String getCoverLetterFilePath({
    required String appDir,
    required String jobTitle,
  }) {
    final sanitizedTitle = _sanitizeName(name: jobTitle);
    return '$appDir/cover_letter_${sanitizedTitle.toLowerCase()}${_getTimestamp()}.md';
  }

  @override
  String getFeedbackFilePath({required String appDir}) {
    return '$appDir/feedback${_getTimestamp()}.md';
  }

  @override
  String getAiResponseFilePath({required String appDir, required String type}) {
    final suffix = type == 'jobreq'
        ? '_ai_response.json'
        : '_ai_responses.json';
    return '$appDir/$type$suffix';
  }

  @override
  Future<Either<Failure, Unit>> validateMarkdownFiles({
    required String directory,
    required String fileExtension,
  }) async {
    try {
      final dir = Directory(directory);
      if (!await dir.exists()) {
        return Left(
          ParsingFailure(message: 'Directory $directory does not exist.'),
        );
      }

      await for (final file in dir.list()) {
        if (file.path.endsWith(fileExtension)) {
          final content = await File(file.path).readAsString();

          // Validate Markdown parsing
          try {
            markdownToHtml(content);
          } catch (e) {
            return Left(
              ParsingFailure(
                message: 'File ${file.path} is not valid Markdown: $e',
              ),
            );
          }
        }
      }

      return Right(unit);
    } catch (e) {
      return Left(
        ServiceFailure(message: 'Failed to validate Markdown files: $e'),
      );
    }
  }

  String _getTimestamp() {
    final now = DateTime.now().toUtc();
    final formatter = DateFormat('yyyyMMdd_HHmmss');
    return '_${formatter.format(now)}';
  }

  String _sanitizeName({required String name}) {
    return name
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(' ', '_')
        .toLowerCase();
  }

  String? _getFieldValue(
    FolderField field,
    JobReq jobReq,
    Applicant applicant,
  ) {
    switch (field) {
      case FolderField.applicant_name:
        return applicant.name;
      case FolderField.jobreq_title:
        return jobReq.title;
      case FolderField.concern:
        return jobReq.concern?.name;
      case FolderField.applicant_location:
        return applicant.address?.city;
      case FolderField.jobreq_location:
        return jobReq.location;
      case FolderField.concern_location:
        return jobReq.concern?.location;
    }
  }
}
