# Basic Resume Generation Example

This example demonstrates how to use the `resumesux_domain` package to generate a resume for a job application.

## Prerequisites

- A running AI service (e.g., LM Studio with a compatible model like Llama or Mistral)
- The AI service should be accessible at `http://127.0.0.1:1234/v1` (default for LM Studio)

## Running the Example

1. Ensure your AI service is running.
2. Run the example:

```bash
dart run main.dart
```

## What it does

1. Sets up an AI service with a local provider.
2. Initializes repositories for digest and job requirements.
3. Loads a sample job requirement from the test data.
4. Creates an applicant profile.
5. Generates a resume tailored to the job using AI.
6. Prints the generated resume content.

## Key Components

- `AiServiceImpl`: Handles AI interactions.
- `DigestRepositoryImpl`: Manages applicant digest data (skills, experience, etc.).
- `JobReqRepositoryImpl`: Handles job requirement processing.
- `GenerateResumeUsecase`: The use case for generating resumes.

This example shows the basic setup and usage pattern for resume generation in the resumesux_domain package.