import 'dart:io';
import 'package:path/path.dart' as path;

/// Factory for creating temporary directories for tests.
/// Uses build/test_temp/ as the base directory.
class TempDirFactory {
  static TempDirFactory? _instance;

  static TempDirFactory get instance {
    _instance ??= TempDirFactory._();
    return _instance!;
  }

  TempDirFactory._();

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
}
