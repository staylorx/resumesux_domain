import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:path/path.dart' as path;
import 'package:resumesux_domain/resumesux_domain.dart';

/// Factory for creating temporary directories for tests.
class TestDirFactory {
  static TestDirFactory? _instance;

  static TestDirFactory get instance {
    _instance ??= TestDirFactory._();
    return _instance!;
  }

  TestDirFactory._();

  /// Base temp directory for tests
  String get _baseTempDir => "build";

  /// Database path for setUpAll (shared across tests)
  String get setUpAllDbPath =>
      path.join(_baseTempDir, 'setUpAll', 'jobreqs.db');

  /// Database path for setUp (per-test setup)
  String get setUpDbPath => path.join(_baseTempDir, 'setUp', 'jobreqs.db');

  /// Output directory for test outputs
  String get outputDir => path.join(_baseTempDir, 'output');

  /// Ensures the temp directories exist
  void ensureTempDirs() {
    Directory(path.dirname(setUpAllDbPath)).createSync(recursive: true);
    Directory(path.dirname(setUpDbPath)).createSync(recursive: true);
    Directory(outputDir).createSync(recursive: true);
  }

  /// Creates a unique directory for a test suite, guaranteed to be unique.
  /// Returns the path to the created directory.
  String createUniqueTestSuiteDir() {
    final now = DateTime.now().toUtc().toIso8601String().replaceAll(':', '-');
    final uniqueName = 'suite_$now';
    final dirPath = path.join(outputDir, uniqueName);
    Directory(dirPath).createSync(recursive: true);
    return dirPath;
  }
}

/// Helper class for creating test AI models and providers.
class TestAiHelper {
  /// Default AI model for testing.
  static AiModel get defaultModel => AiModel(
    // name: 'qwen/qwen2.5-coder-14b',
    // name: "google/gemma-3-12b",
    name: "qwen2.5-7b-instruct",
    isDefault: true,
    settings: {'temperature': 0.8},
  );

  /// Default AI provider for testing.
  static AiProvider get defaultProvider => AiProvider(
    id: 'lmstudio',
    url: 'http://127.0.0.1:1234/v1',
    key: 'dummy-key',
    models: [defaultModel],
    defaultModel: defaultModel,
    settings: {'max_tokens': 4000, 'temperature': 0.8},
    isDefault: true,
  );
}

/// Test implementation of FileRepository for testing purposes.
/// Returns a fixed path for createApplicationDirectory and generates file paths with timestamps.
class TestFileRepository implements FileRepository {
  @override
  Either<Failure, String> readFile(String path) {
    // Return dummy content for testing
    return const Right('test file content');
  }

  @override
  Future<Either<Failure, Unit>> writeFile(String path, String content) async {
    try {
      File(path).writeAsStringSync(content);
      return const Right(unit);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to write file: $e'));
    }
  }

  @override
  Either<Failure, Unit> createDirectory(String path) {
    // Do nothing for testing
    return const Right(unit);
  }

  @override
  Either<Failure, Unit> validateDirectory(String path) {
    // Always valid for testing
    return const Right(unit);
  }

  @override
  Either<Failure, String> createApplicationDirectory({
    required String baseOutputDir,
    required JobReq jobReq,
  }) {
    // Sanitize company name for concernDir
    final companyName = jobReq.concern?.name ?? 'unknown_company';
    final sanitizedCompany = companyName
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
    final concernDir = path.join(baseOutputDir, sanitizedCompany);

    // Sanitize job title for dirName
    final sanitizedTitle = jobReq.title
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final dirName = '${timestamp}_$sanitizedTitle';
    final appDir = path.join(concernDir, dirName);

    try {
      Directory(appDir).createSync(recursive: true);
      return Right(appDir);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to create app dir: $e'));
    }
  }

  @override
  String getResumeFilePath({required String appDir, required String jobTitle}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return path.join(appDir, 'resume_$timestamp.md');
  }

  @override
  String getCoverLetterFilePath({
    required String appDir,
    required String jobTitle,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return path.join(appDir, 'cover_letter_$timestamp.md');
  }

  @override
  String getFeedbackFilePath({required String appDir}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return path.join(appDir, 'feedback_$timestamp.md');
  }

  @override
  String getAiResponseFilePath({required String appDir, required String type}) {
    final suffix = type == 'jobreq' ? '_ai_response.json' : '_ai_responses.json';
    return path.join(appDir, '$type$suffix');
  }

  @override
  Future<Either<Failure, Unit>> validateMarkdownFiles({
    required String directory,
    required String fileExtension,
  }) async {
    // Always valid for testing
    return const Right(unit);
  }
}
