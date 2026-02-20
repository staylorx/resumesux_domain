# ResumesUX Domain

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://pub.dev/packages/resumesux_domain)
[![License](https://img.shields.io/badge/license-Apache%202.0-green.svg)](LICENSE)

A Dart package providing domain entities and value objects for resume and job application management. This package implements the domain layer following Clean Architecture principles, featuring immutable entities, value objects, and enums for type-safe business logic.

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  resumesux_domain:
    path: ../path/to/resumesux_domain
```

Then run:

```bash
flutter pub get
# or
dart pub get
```

## Usage

Import the package in your Dart code:

```dart
import 'package:resumesux_domain/resumesux_domain.dart';
```

### Basic Example

Create an applicant entity:

```dart
final applicant = Applicant(
  name: 'John Doe',
  email: 'john.doe@example.com',
  phone: '+1-555-0123',
  linkedin: 'https://linkedin.com/in/johndoe',
  gigs: [
    Gig(
      title: 'Software Engineer',
      company: 'Tech Corp',
      description: 'Developed mobile applications using Flutter',
      startDate: DateTime(2020, 1, 1),
      endDate: DateTime(2023, 12, 31),
    ),
  ],
  assets: [],
);
```

Create a resume:

```dart
final resume = Resume(
  content: '# John Doe\n\nExperienced software engineer...',
  contentType: 'text/markdown',
);
```

## API Overview

### Core Entities

- **`Applicant`**: Job applicant with personal info, experience, and assets
- **`Resume`**: Resume document content
- **`JobReq`**: Job requirement details
- **`Application`**: Complete job application
- **`CoverLetter`**: Cover letter content
- **`Feedback`**: Application feedback
- **`Gig`**: Work experience entry
- **`Asset`**: Additional applicant assets
- **`Config`**: Application configuration
- **`AiProvider`**: AI provider information
- **`AiResponse`**: AI service responses
- **`Concern`**: Job matching criteria

### Value Objects

- **`Address`**: Structured address
- **`AiModel`**: AI model specifications
- **`Tags`**: Categorization tags
- **`Handles`**: Unique entity identifiers (ApplicantHandle, ApplicationHandle, etc.)

### Enums

- **`FolderField`**: Folder organization fields

### Base Classes

- **`Doc`**: Abstract base for document types

## Architecture

This package follows Clean Architecture principles:

- **Domain Layer**: Business logic, entities, value objects, and enums
- Framework-agnostic design for use with any Dart/Flutter presentation framework

## Testing

Unit tests are included for entities and value objects. Run tests with:

```bash
flutter test
# or
dart test
```

## Contributing

Contributions are welcome! Please ensure changes maintain Clean Architecture principles and include tests.

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.