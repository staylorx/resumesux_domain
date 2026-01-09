import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

// Mock classes
class MockHttpClient extends Mock implements http.Client {}

class MockResponse extends Mock implements http.Response {}

class FakeUri extends Fake implements Uri {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUri());
    registerFallbackValue('');
    registerFallbackValue(<String, String>{});
    registerFallbackValue(<String, dynamic>{});
  });
  late ConfigRepositoryImpl configRepository;
  late ConfigDatasource configDatasource;
  late AiService aiService;
  late MockHttpClient mockHttpClient;

  setUp(() {
    configDatasource = ConfigDatasource();
    configRepository = ConfigRepositoryImpl(configDatasource: configDatasource);
    mockHttpClient = MockHttpClient();
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
        (p) => p.id == 'lmstudio',
      );
      expect(lmstudioProvider.url, 'http://127.0.0.1:1234');
      expect(lmstudioProvider.key, 'dummy-key');
      expect(lmstudioProvider.isDefault, true);
      expect(lmstudioProvider.models.length, 1);
      expect(lmstudioProvider.defaultModel?.name, 'qwen/qwen2.5-coder-14b');

      final openaiProvider = config.providers.firstWhere(
        (p) => p.id == 'openai',
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
      expect(provider.id, 'testprovider');
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

  group('AI Provider Selection Integration Tests', () {
    test('get default provider successfully', () async {
      // Arrange
      final configPath = 'test/data/config/valid_config.yaml';

      // Act
      final result = await configRepository.getDefaultProvider(
        configPath: configPath,
      );

      // Assert
      expect(result.isRight(), true);
      final provider = result.getOrElse(
        (_) => throw Exception('Failed to get provider'),
      )!;
      expect(provider.id, 'lmstudio');
      expect(provider.isDefault, true);
      expect(provider.defaultModel?.name, 'qwen/qwen2.5-coder-14b');
    });

    test('get specific provider by name', () async {
      // Arrange
      final configPath = 'test/data/config/valid_config.yaml';

      // Act
      final result = await configRepository.getProvider(
        providerName: 'openai',
        configPath: configPath,
      );

      // Assert
      expect(result.isRight(), true);
      final provider = result.getOrElse(
        (_) => throw Exception('Failed to get provider'),
      );
      expect(provider.id, 'openai');
      expect(provider.isDefault, false);
      expect(provider.defaultModel?.name, 'gpt-4');
    });

    test('fail to get non-existent provider', () async {
      // Arrange
      final configPath = 'test/data/config/valid_config.yaml';

      // Act
      final result = await configRepository.getProvider(
        providerName: 'nonexistent',
        configPath: configPath,
      );

      // Assert
      expect(result.isLeft(), true);
      final failure = result.getLeft().toNullable()!;
      expect(failure, isA<NotFoundFailure>());
      expect(failure.message, contains('Provider nonexistent not found'));
    });

    test('check if provider has default model', () async {
      // Arrange
      final configPath = 'test/data/config/valid_config.yaml';
      final configResult = await configRepository.loadConfig(
        configPath: configPath,
      );
      expect(configResult.isRight(), true);
      final config = configResult.getOrElse(
        (_) => throw Exception('Failed to load config'),
      );
      final provider = config.providers.firstWhere((p) => p.id == 'lmstudio');

      // Act
      final hasDefault = configRepository.hasDefaultModel(provider: provider);

      // Assert
      expect(hasDefault, true);
    });
  });

  group('AI Service Integration Tests', () {
    test('create AiService with valid provider', () async {
      // Arrange
      final configPath = 'test/data/config/valid_config.yaml';

      // Act
      aiService = await AiService.create(
        configRepository: configRepository,
        providerName: 'lmstudio',
        configPath: configPath,
        httpClient: mockHttpClient,
      );

      // Assert
      expect(aiService.provider.id, 'lmstudio');
      expect(aiService.provider.defaultModel?.name, 'qwen/qwen2.5-coder-14b');
    });

    test('generate content with mocked successful response', () async {
      // Arrange
      final configPath = 'test/data/config/valid_config.yaml';
      aiService = await AiService.create(
        configRepository: configRepository,
        providerName: 'lmstudio',
        configPath: configPath,
        httpClient: mockHttpClient,
      );

      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.body).thenReturn('''
{
  "choices": [
    {
      "message": {
        "content": "Generated content from AI"
      }
    }
  ]
}
''');

      when(
        () => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await aiService.generateContent(prompt: 'Test prompt');

      // Assert
      expect(result.isRight(), true);
      final content = result.getOrElse((_) => '');
      expect(content, 'Generated content from AI');

      verify(
        () => mockHttpClient.post(
          Uri.parse('http://127.0.0.1:1234/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer dummy-key',
          },
          body: any(named: 'body'),
        ),
      ).called(1);
    });

    test('handle API failure response', () async {
      // Arrange
      final configPath = 'test/data/config/valid_config.yaml';
      aiService = await AiService.create(
        configRepository: configRepository,
        providerName: 'lmstudio',
        configPath: configPath,
        httpClient: mockHttpClient,
      );

      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(500);
      when(() => mockResponse.body).thenReturn('Internal Server Error');

      when(
        () => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await aiService.generateContent(prompt: 'Test prompt');

      // Assert
      expect(result.isLeft(), true);
      final failure = result.getLeft().toNullable()!;
      expect(failure, isA<ServiceFailure>());
      expect(failure.message, contains('API request failed: 500'));
    });

    test('handle network failure', () async {
      // Arrange
      final configPath = 'test/data/config/valid_config.yaml';
      aiService = await AiService.create(
        configRepository: configRepository,
        providerName: 'lmstudio',
        configPath: configPath,
        httpClient: mockHttpClient,
      );

      when(
        () => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenThrow(Exception('Network error'));

      // Act
      final result = await aiService.generateContent(prompt: 'Test prompt');

      // Assert
      expect(result.isLeft(), true);
      final failure = result.getLeft().toNullable()!;
      expect(failure, isA<NetworkFailure>());
      expect(failure.message, contains('Failed to generate content'));
    });
  });

  group('End-to-End Functional Tests', () {
    test(
      'complete workflow: load config, select provider, generate content',
      () async {
        // Arrange
        final configPath = 'test/data/config/valid_config.yaml';

        // Get default provider
        final providerResult = await configRepository.getDefaultProvider(
          configPath: configPath,
        );
        expect(providerResult.isRight(), true);
        final provider = providerResult.getOrElse(
          (_) => throw Exception('Failed to get provider'),
        )!;

        // Create AI service
        aiService = AiService(httpClient: mockHttpClient, provider: provider);

        // Mock successful AI response
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.body).thenReturn('''
{
  "choices": [
    {
      "message": {
        "content": "Professional resume content generated successfully"
      }
    }
  ]
}
''');

        when(
          () => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final contentResult = await aiService.generateContent(
          prompt:
              'Generate a professional resume for a software engineer position',
        );

        // Assert
        expect(contentResult.isRight(), true);
        final content = contentResult.getOrElse((_) => '');
        expect(content, isNotEmpty);
        expect(content, contains('Professional resume content'));
      },
    );
  });
}
