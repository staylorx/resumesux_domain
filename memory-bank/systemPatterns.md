# System Patterns

This file documents recurring patterns and architectural principles used in the system.

## Clean Architecture Principles

The codebase strictly follows Clean Architecture with clear layer separation:

- **Entities**: Pure business objects (Applicant, JobReq, Resume, etc.) with no external dependencies
- **Use Cases**: Application logic orchestrating entities, injected with repository interfaces
- **Adapters**: Repository implementations connecting use cases to external systems (database, AI services)
- **Frameworks**: External libraries and infrastructure (Sembast, HTTP clients)

Dependencies flow inward only; no entity touches data layer directly.

## Functional Programming with fpdart

- Uses `Either<Failure, T>` for error handling instead of exceptions
- `TaskEither` for async operations
- Dependency injection via constructor parameters, no global state

## Repository Pattern

- Domain defines repository interfaces (e.g., `ApplicantRepository`)
- Data layer implements concrete repositories (e.g., `ApplicantRepositoryImpl`)
- Use cases depend on abstractions, injected at runtime

## AI Service Integration

- `AiService` interface abstracts AI provider details
- Supports multiple providers (LM Studio, Ollama) via configuration
- AI responses cached and saved for debugging/testing

## Configuration Management

- YAML-based configuration with schema validation
- Supports multiple AI providers and models
- Environment-specific settings

## Testing Patterns

- Unit tests for pure functions and entities
- Integration tests for end-to-end workflows with mocked AI services
- Benchmark tests for performance-critical operations
- Mocktail for mocking dependencies

## Error Handling

- Custom `Failure` types for domain-specific errors
- Either monad for propagating failures through layers
- No throwing exceptions in domain layer