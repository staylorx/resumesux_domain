import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as path;
import 'package:resumesux_domain/resumesux_domain.dart';

/// Factory for creating temporary directories for tests.
/// Uses build/test_temp/ as the base directory.
class TestDirFactory {
  static TestDirFactory? _instance;

  static TestDirFactory get instance {
    _instance ??= TestDirFactory._();
    return _instance!;
  }

  TestDirFactory._();

  /// Base temp directory for tests
  String get _baseTempDir => path.join('build', 'test_temp');

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
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(10000);
    final uniqueName = 'suite_${timestamp}_$random';
    final dirPath = path.join(_baseTempDir, uniqueName);
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
