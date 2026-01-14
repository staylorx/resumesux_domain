import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:test_suite_tool/test_suite_tool.dart';

void main() {
  late String tempDir;
  late TestSuiteTool suite;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('test_suite_tool_test_').path;
    suite = TestSuiteTool(
      config: const SuiteDirConfig(type: SuiteDirType.temporary),
      suiteName: 'Test Suite',
    );
  });

  tearDown(() {
    Directory(tempDir).deleteSync(recursive: true);
    suite.dispose();
  });

  test('initialize creates directory and README', () {
    suite.initialize();

    expect(Directory(suite.suiteDir!).existsSync(), isTrue);
    expect(File(path.join(suite.suiteDir!, 'README.md')).existsSync(), isTrue);
  });

  test('startGroup and startTest update state', () {
    suite.initialize();
    suite.startGroup('Group 1');
    suite.startTest('Test 1');

    expect(suite.groups, contains('Group 1'));
    expect(suite.testEntries, contains('Test 1'));
  });

  test('endTest updates status', () {
    suite.initialize();
    suite.startTest('Test 1');
    suite.endTest('Test 1', true);

    expect(suite.testEntries['Test 1']?.status, TestStatus.passed);
  });

  test('collectArtifact copies file', () {
    suite.initialize();

    final sourceFile = File(path.join(tempDir, 'source.txt'));
    sourceFile.writeAsStringSync('test content');

    suite.collectArtifact(sourceFile.path);

    final destFile = File(path.join(suite.suiteDir!, 'source.txt'));
    expect(destFile.existsSync(), isTrue);
    expect(destFile.readAsStringSync(), 'test content');
  });

  test('collectArtifact with destName', () {
    suite.initialize();

    final sourceFile = File(path.join(tempDir, 'source.txt'));
    sourceFile.writeAsStringSync('test content');

    suite.collectArtifact(sourceFile.path, destName: 'renamed.txt');

    final destFile = File(path.join(suite.suiteDir!, 'renamed.txt'));
    expect(destFile.existsSync(), isTrue);
  });

  group('persisted suite', () {
    late String persistedTempDir;
    late TestSuiteTool persistedSuite;

    setUp(() {
      persistedTempDir = Directory.systemTemp.createTempSync('test_suite_tool_test_persisted_').path;
      persistedSuite = TestSuiteTool(
        config: SuiteDirConfig(
          type: SuiteDirType.persisted,
          basePath: persistedTempDir,
          deleteOnTeardown: true,
        ),
        suiteName: 'Test Suite Persisted',
      );
    });

    tearDown(() {
      persistedSuite.dispose();
      Directory(persistedTempDir).deleteSync(recursive: true);
    });

    test('creates directory in specified basePath', () {
      persistedSuite.initialize();

      expect(Directory(persistedSuite.suiteDir!).existsSync(), isTrue);
      expect(persistedSuite.suiteDir, path.join(persistedTempDir, 'Test Suite Persisted'));
    });
  });
}