import 'dart:io';
import 'package:path/path.dart' as path;

/// Manages README.md file for test suites, tracking progress and status.
class TestSuiteReadmeManager {
  final String suiteDir;
  final String suiteName;
  final DateTime startTime;
  final List<String> groups = [];
  final Map<String, TestEntry> testEntries = {};
  final Map<String, List<TestEntry>> groupTests = {};
  String? currentGroup;

  TestSuiteReadmeManager({required this.suiteDir, required this.suiteName})
      : startTime = DateTime.now();

  /// Initializes the README.md with suite information.
  void initialize() {
    _writeReadme();
  }

  /// Records the start of a test group.
  void startGroup(String groupName) {
    groups.add(groupName);
    currentGroup = groupName;
    groupTests[groupName] = [];
    _writeReadme();
  }

  /// Records the start of a test.
  void startTest(String testName) {
    final entry = TestEntry(
      name: testName,
      startTime: DateTime.now(),
      status: TestStatus.running,
    );
    testEntries[testName] = entry;
    if (currentGroup != null) {
      groupTests[currentGroup!]!.add(entry);
    } else {
      const defaultGroup = 'General';
      if (!groups.contains(defaultGroup)) {
        groups.add(defaultGroup);
        groupTests[defaultGroup] = [];
      }
      groupTests[defaultGroup]!.add(entry);
    }
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

    buffer.writeln('# Test Suite: $suiteName - GROUPED');
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
      for (final group in groups) {
        buffer.writeln('## $group');
        buffer.writeln('');
        final tests = groupTests[group] ?? [];
        if (tests.isNotEmpty) {
          buffer.writeln('| Test | Status | Duration | Error |');
          buffer.writeln('|------|--------|----------|-------|');

          for (final entry in tests) {
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
        }
      }

      final passed =
          testEntries.values.where((e) => e.status == TestStatus.passed).length;
      final failed =
          testEntries.values.where((e) => e.status == TestStatus.failed).length;
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
