# Examples

This directory contains examples demonstrating how to use the `resumesux_domain` package effectively. Each example is a self-contained Dart project that shows different aspects of the package's functionality.

## Available Examples

### 1. Basic Resume Generation (`basic_resume_generation/`)

A simple example showing how to set up the basic components and generate a resume for a job application.

**What it covers:**
- Setting up AI service and database
- Loading job requirements
- Creating applicant profiles
- Generating resumes with AI

**Run it:**
```bash
cd basic_resume_generation
dart pub get
dart run main.dart
```

### 2. Full Application Generation (`full_application_generation/`)

A comprehensive example demonstrating the complete workflow for generating job applications, including resume, cover letter, and feedback.

**What it covers:**
- Full application generation workflow
- Multiple repositories and use cases
- File management and saving artifacts
- Progress tracking

**Run it:**
```bash
cd full_application_generation
dart pub get
dart run main.dart
```

### 3. Configuration and Applicant Setup (`configuration_and_applicant_setup/`)

An example focused on creating and configuring the core entities like Config, Applicant, AiProvider, and AiModel.

**What it covers:**
- Creating AI providers and models
- Setting up applicant information
- Building configuration objects
- Understanding the data structures

**Run it:**
```bash
cd configuration_and_applicant_setup
dart pub get
dart run main.dart
```

## Prerequisites

Most examples require a running AI service for actual content generation. We recommend:

- **LM Studio**: Download from [lmstudio.ai](https://lmstudio.ai/), load a compatible model (e.g., Llama or Mistral), and start the local server on `http://localhost:1234`.
- **Ollama**: Install from [ollama.ai](https://ollama.ai/), pull a model with `ollama pull llama2`, and run the server.

## Architecture Notes

All examples follow Clean Architecture principles:
- **Domain Layer**: Entities, use cases, and business logic
- **Data Layer**: Repositories, data sources, and external integrations
- **Presentation Layer**: Not included (examples are command-line)

The examples demonstrate dependency injection and proper separation of concerns.

## Learning Path

Start with `configuration_and_applicant_setup` to understand the data structures, then move to `basic_resume_generation` for simple usage, and finally `full_application_generation` for the complete workflow.

## Troubleshooting

- Ensure your AI service is running and accessible
- Check that the package dependencies are installed with `dart pub get`
- Verify file paths in examples match your setup
- For Windows users, ensure paths use forward slashes or proper escaping

## Contributing

If you create additional examples, please follow the same structure:
- `pubspec.yaml` with dependency on `resumesux_domain`
- `main.dart` as the entry point
- `README.md` explaining the example
- Clear, commented code demonstrating best practices