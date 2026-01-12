# Configuration and Applicant Setup Example

This example demonstrates how to create and configure the core entities in `resumesux_domain`: Config, Applicant, AiProvider, and AiModel.

## Running the Example

```bash
dart run main.dart
```

## What it does

1. Creates AI providers (LM Studio and Ollama) with their models and settings.
2. Creates an applicant profile with personal and professional information.
3. Creates a configuration object that ties everything together.
4. Displays all the configured information.

## Key Components

- `AiProvider`: Represents an AI service provider with URL, API key, models, and settings.
- `AiModel`: Represents a specific AI model with name and settings.
- `Applicant`: Contains personal information like name, contact details, and address.
- `Address`: Represents a physical address with optional fields.
- `Config`: The main configuration object that holds all settings and the applicant info.

This example shows how to structure configuration data for the resumesux_domain package without relying on external config files.