import 'package:test/test.dart';
import 'package:resumesux_domain/resumesux_domain.dart';
import 'package:resumesux_domain/src/data/data.dart';

void main() {
  late ConfigRepositoryImpl configRepository;
  late ConfigDatasource configDatasource;

  setUp(() {
    configDatasource = ConfigDatasource();
    configRepository = ConfigRepositoryImpl(configDatasource: configDatasource);
  });

  group('Config Loading Integration Tests', () {
    test('load valid config file successfully', () async {
      // Arrange
      final configPath = 'test/data/config/valid_config.yaml';

      // Act
      final result = await configRepository.loadConfig(configPath: configPath);

      // Assert
      expect(result.isRight(), true);
      final config = result.getOrElse(
        (_) => throw Exception('Failed to load config'),
      );

      expect(config.outputDir, 'output');
      expect(config.includeCover, true);
      expect(config.includeFeedback, true);
      expect(
        config.customPrompt,
        'Generate professional content tailored to the job requirements.',
      );
      expect(config.digestPath, 'digest');
      expect(config.appendPrompt, false); // default value

      // Check applicant
      expect(config.applicant.name, 'John Doe');
      expect(config.applicant.preferredName, 'John');
      expect(config.applicant.email, 'john.doe@example.com');
      expect(config.applicant.address!.street1, '123 Main St');
      expect(config.applicant.address!.city, 'Anytown');
      expect(config.applicant.phone, '(555) 123-4567');

      // Check providers
      expect(config.providers.length, 2);

      final lmstudioProvider = config.providers.firstWhere(
        (p) => p.name == 'lmstudio',
      );
      expect(lmstudioProvider.url, 'http://127.0.0.1:1234');
      expect(lmstudioProvider.key, 'dummy-key');
      expect(lmstudioProvider.isDefault, true);
      expect(lmstudioProvider.models.length, 1);
      expect(lmstudioProvider.defaultModel?.name, 'qwen/qwen2.5-coder-14b');

      final openaiProvider = config.providers.firstWhere(
        (p) => p.name == 'openai',
      );
      expect(openaiProvider.url, 'https://api.openai.com/v1');
      expect(openaiProvider.key, 'sk-test-key');
      expect(openaiProvider.isDefault, false);
      expect(openaiProvider.models.length, 1);
      expect(openaiProvider.defaultModel?.name, 'gpt-4');
    });

    test('load minimal config file with defaults', () async {
      // Arrange
      final configPath = 'test/data/config/minimal_config.yaml';

      // Act
      final result = await configRepository.loadConfig(configPath: configPath);

      // Assert
      expect(result.isRight(), true);
      final config = result.getOrElse(
        (_) => throw Exception('Failed to load config'),
      );

      expect(config.outputDir, 'output');
      expect(config.includeCover, false);
      expect(config.includeFeedback, false);
      expect(config.customPrompt, ''); // default empty string
      expect(config.digestPath, 'digest'); // default value
      expect(config.appendPrompt, false); // default value

      // Check applicant
      expect(config.applicant.name, 'Jane Smith');
      expect(
        config.applicant.address!.zip,
        '67890',
      ); // number converted to string

      // Check providers
      expect(config.providers.length, 1);
      final provider = config.providers.first;
      expect(provider.name, 'testprovider');
      expect(provider.models.length, 1);
      expect(provider.defaultModel?.name, 'test-model');
      expect(provider.isDefault, true); // default specified
    });

    test('fail to load invalid config file', () async {
      // Arrange
      final configPath = 'test/data/config/invalid_config.yaml';

      // Act
      final result = await configRepository.loadConfig(configPath: configPath);

      // Assert
      expect(result.isLeft(), true);
      final failure = result.getLeft().toNullable()!;
      expect(failure, isA<ValidationFailure>());
      expect(failure.message, contains('must have exactly one model with'));
    });

    test('fail to load config with multiple default providers', () async {
      // Arrange
      final configPath =
          'test/data/config/invalid_multiple_defaults_config.yaml';

      // Act
      final result = await configRepository.loadConfig(configPath: configPath);

      // Assert
      expect(result.isLeft(), true);
      final failure = result.getLeft().toNullable()!;
      expect(failure, isA<ValidationFailure>());
      expect(failure.message, contains('must have exactly one provider with'));
    });

    test('fail to load non-existent config file', () async {
      // Arrange
      final configPath = 'test/data/config/non_existent.yaml';

      // Act
      final result = await configRepository.loadConfig(configPath: configPath);

      // Assert
      expect(result.isLeft(), true);
      final failure = result.getLeft().toNullable()!;
      expect(failure, isA<NotFoundFailure>());
    });
  });
}
