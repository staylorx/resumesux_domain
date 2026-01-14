# Test Suite Tool

A Dart package providing a tool and mixin for managing test suites, including automatic README generation and suite directory handling for collecting test artifacts.

## Features

- Automatic creation of test suite directories (temporary or persisted)
- Configurable directory handling with teardown options
- Real-time README.md generation with test progress tracking
- Test grouping and status monitoring
- Artifact collection for test outputs
- Mixin-based design for easy integration

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  test_suite_tool: ^0.2.0
```

## Usage

### Using the TestSuiteTool Class

```dart
import 'package:test_suite_tool/test_suite_tool.dart';

void main() {
  final suite = TestSuiteTool(
    config: SuiteDirConfig(
      type: SuiteDirType.persisted,
      basePath: './test_output',
      deleteOnTeardown: false, // Keep for inspection
    ),
    suiteName: 'My Test Suite',
  );

  suite.initialize();

  suite.startGroup('Integration Tests');
  suite.startTest('Login Test');
  // Run your test
  suite.endTest('Login Test', true); // passed

  suite.startTest('Signup Test');
  // Run test
  suite.endTest('Signup Test', false, error: 'Failed to validate email');

  suite.finalize();
  suite.dispose(); // Deletes directory if configured
}
```

### Suite Directory Configuration

The `SuiteDirConfig` allows you to control how the suite directory is created:

- `type`: `SuiteDirType.temporary` (uses system temp directory) or `SuiteDirType.persisted` (uses specified base path)
- `basePath`: Base directory for persisted suites (defaults to `build/output`)
- `deleteOnTeardown`: Whether to delete the directory when `dispose()` is called (defaults to `true`)

For temporary suites:
```dart
final config = SuiteDirConfig(type: SuiteDirType.temporary);
```

For persisted suites:
```dart
final config = SuiteDirConfig(
  type: SuiteDirType.persisted,
  basePath: './my_test_outputs',
  deleteOnTeardown: false, // Keep for manual inspection
);
```

### Using the TestSuiteMixin

```dart
import 'package:test_suite_tool/test_suite_tool.dart';

class MyTestRunner with TestSuiteMixin {
  MyTestRunner(SuiteDirConfig config, String suiteName) {
    this.config = config;
    this.suiteName = suiteName;
  }

  void runTests() {
    initialize();

    // Your test logic here
    startGroup('Unit Tests');
    startTest('Calculator Test');
    // Test code
    endTest('Calculator Test', true);

    finalize();
    dispose();
  }
}
```

### Collecting Artifacts

```dart
suite.collectArtifact('./logs/test_log.txt');
suite.collectArtifact('./screenshots/failure.png', destName: 'error_screenshot.png');
```

## Generated README Structure

The package generates a README.md in the suite directory with:

- Suite information and start time
- Test groups and their tests
- Status indicators (✅ passed, ❌ failed, ⏳ running)
- Duration and error details
- Summary statistics

## License

This package is licensed under the same license as the parent project.