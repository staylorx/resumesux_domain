import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:path/path.dart' as path;
import 'package:resumesux_domain/resumesux_domain.dart';
import 'package:id_logging/id_logging.dart';

/// Manages README.md file for test suites, tracking progress and status.
class TestSuiteReadmeManager {
  final String suiteDir;
  final String suiteName;
  final DateTime startTime;
  final List<String> groups = [];
  final Map<String, TestEntry> testEntries = {};

  TestSuiteReadmeManager({required this.suiteDir, required this.suiteName})
    : startTime = DateTime.now();

  /// Initializes the README.md with suite information.
  void initialize() {
    _writeReadme();
  }

  /// Records the start of a test group.
  void startGroup(String groupName) {
    groups.add(groupName);
    _writeReadme();
  }

  /// Records the start of a test.
  void startTest(String testName) {
    testEntries[testName] = TestEntry(
      name: testName,
      startTime: DateTime.now(),
      status: TestStatus.running,
    );
    _writeReadme();
  }

  /// Records the end of a test with its status.
  void endTest(String testName, bool passed, {String? error}) {
    final entry = testEntries[testName];
    if (entry != null) {
      entry.endTime = DateTime.now();
      entry.status = passed ? TestStatus.passed : TestStatus.failed;
      entry.error = error;
      _writeReadme();
    }
  }

  /// Finalizes the README with summary.
  void finalize() {
    _writeReadme();
  }

  void _writeReadme() {
    final buffer = StringBuffer();

    buffer.writeln('# Test Suite: $suiteName');
    buffer.writeln('');
    buffer.writeln('Started: ${startTime.toIso8601String()}');
    buffer.writeln('Suite Directory: $suiteDir');
    buffer.writeln('');

    if (groups.isNotEmpty) {
      buffer.writeln('## Test Groups');
      for (final group in groups) {
        buffer.writeln('- $group');
      }
      buffer.writeln('');
    }

    if (testEntries.isNotEmpty) {
      buffer.writeln('## Test Results');
      buffer.writeln('');
      buffer.writeln('| Test | Status | Duration | Error |');
      buffer.writeln('|------|--------|----------|-------|');

      for (final entry in testEntries.values) {
        final duration = entry.endTime != null
            ? '${entry.endTime!.difference(entry.startTime).inSeconds}s'
            : 'Running';
        final statusEmoji = entry.status == TestStatus.passed
            ? '✅'
            : entry.status == TestStatus.failed
            ? '❌'
            : '⏳';
        final error = entry.error ?? '';
        buffer.writeln(
          '| ${entry.name} | $statusEmoji ${entry.status.name} | $duration | $error |',
        );
      }
      buffer.writeln('');

      final passed = testEntries.values
          .where((e) => e.status == TestStatus.passed)
          .length;
      final failed = testEntries.values
          .where((e) => e.status == TestStatus.failed)
          .length;
      final running = testEntries.values
          .where((e) => e.status == TestStatus.running)
          .length;

      buffer.writeln('## Summary');
      buffer.writeln('- Total Tests: ${testEntries.length}');
      buffer.writeln('- Passed: $passed');
      buffer.writeln('- Failed: $failed');
      buffer.writeln('- Running: $running');
    }

    final readmePath = path.join(suiteDir, 'README.md');
    File(readmePath).writeAsStringSync(buffer.toString());
  }
}

/// Represents a test entry in the README.
class TestEntry {
  final String name;
  final DateTime startTime;
  DateTime? endTime;
  TestStatus status;
  String? error;

  TestEntry({
    required this.name,
    required this.startTime,
    required this.status,
  });
}

/// Enum for test status.
enum TestStatus { running, passed, failed }

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

  /// Output directory for test outputs
  String get outputDir => path.join(_baseTempDir, 'output');

  /// Ensures the temp directories exist
  void ensureTempDirs() {
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
    name: 'lmstudio',
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
class TestFileRepository with Loggable implements FileRepository {
  TestFileRepository();
  @override
  Either<Failure, String> readFile({required String path}) {
    // Return dummy content for testing
    return const Right('test file content');
  }

  @override
  Future<Either<Failure, Unit>> writeFile({
    required String path,
    required String content,
  }) async {
    try {
      File(path).writeAsStringSync(content);
      return const Right(unit);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to write file: $e'));
    }
  }

  @override
  Either<Failure, Unit> createDirectory({required String path}) {
    // Do nothing for testing
    return const Right(unit);
  }

  @override
  Either<Failure, Unit> validateDirectory({required String path}) {
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
      logger?.debug('Creating app dir: $appDir');
      Directory(appDir).createSync(recursive: true);
      return Right(appDir);
    } catch (e) {
      logger?.warning('Failed to create app dir: $appDir, error: $e');
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
    final suffix = type == 'jobreq'
        ? '_ai_response.json'
        : '_ai_responses.json';
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
