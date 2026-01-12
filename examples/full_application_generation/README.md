# Full Application Generation Example

This example demonstrates how to use the `resumesux_domain` package to generate a complete job application, including resume, cover letter, and feedback.

## Prerequisites

- A running AI service (e.g., LM Studio with a compatible model)
- The AI service should be accessible at `http://127.0.0.1:1234/v1`

## Running the Example

1. Ensure your AI service is running.
2. Run the example:

```bash
dart run main.dart
```

## What it does

1. Sets up AI service, database, and all necessary repositories.
2. Loads a sample job requirement.
3. Creates an applicant profile.
4. Generates a complete application with:
   - Resume tailored to the job
   - Cover letter
   - Feedback on the application
5. Saves all artifacts to the output directory.

## Key Components

- `GenerateApplicationUsecase`: Orchestrates the full application generation process.
- Multiple repositories: Digest, JobReq, Resume, CoverLetter, Application.
- File repository for saving generated documents.
- Database for persisting application data.

This example shows the comprehensive workflow for generating and managing job applications using the resumesux_domain package.