# Resume Suckage Domain

A clean architecture Dart package for resume and job application generation using AI. This package provides the domain and data layers for the ResumesUX application, including entities, use cases, and data repositories with AI service integration. Supports multiple AI providers like LM Studio.

## Features

- Clean architecture implementation (domain, data, presentation layers)
- AI-powered resume and cover letter generation
- Support for multiple AI providers
- Job requirement preprocessing
- Feedback generation for applications

## Testing

This package includes comprehensive unit and integration tests. Integration tests that involve AI generation require a local AI provider to be running.

### Using LM Studio

We primarily use LM Studio for testing AI integrations:

1. Download and install LM Studio from [lmstudio.ai](https://lmstudio.ai/)
2. Download a compatible model (e.g., a Llama or Mistral model)
3. Start the local server in LM Studio (typically on `http://localhost:1234`)
4. Ensure your `config.yaml` is configured to use the local LM Studio endpoint
5. Run tests with `flutter test` or `dart test`

### Using Ollama

Ollama is also compatible and can be used as an alternative:

1. Install Ollama from [ollama.ai](https://ollama.ai/)
2. Pull a model: `ollama pull llama2` (or another compatible model)
3. Start the Ollama server
4. Configure your `config.yaml` to point to the Ollama endpoint (usually `http://localhost:11434/v1`)
5. Run tests as usual

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
