import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:resumesux_domain/resumesux_domain.dart';
import 'package:resumesux_domain/src/data/data.dart';

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
  late ConfigRepository configRepository;
  late ConfigDatasource configDatasource;
  late AiService aiService;
  late MockHttpClient mockHttpClient;

  setUp(() {
    configDatasource = createConfigDatasource();
    configRepository = createConfigRepositoryImpl(
      configDatasource: configDatasource,
    );
    mockHttpClient = MockHttpClient();
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
      );
      expect(provider.name, 'lmstudio');
      expect(provider.isDefault, true);
      expect(provider.defaultModel!.name, 'qwen/qwen2.5-coder-14b');
    });

    test('get default model successfully', () async {
      // Arrange
      final configPath = 'test/data/config/valid_config.yaml';

      // Act
      final result = await configRepository.getDefaultModel(
        configPath: configPath,
      );

      // Assert
      expect(result.isRight(), true);
      final model = result.getOrElse(
        (_) => throw Exception('Failed to get model'),
      );
      expect(model.name, 'qwen/qwen2.5-coder-14b');
      expect(model.isDefault, true);
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
      expect(provider.name, 'openai');
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
      final provider = config.providers.firstWhere((p) => p.name == 'lmstudio');

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
      final aiServiceResult = await AiServiceFactoryImpl.createAiServiceStatic(
        configRepository: configRepository,
        providerName: 'lmstudio',
        configPath: configPath,
        httpClient: mockHttpClient,
      );
      expect(aiServiceResult.isRight(), true);
      aiService = aiServiceResult.getOrElse(
        (_) => throw Exception('Failed to create AI service'),
      );

      // Assert
      expect((aiService as AiServiceImpl).provider.name, 'lmstudio');
      expect(
        (aiService as AiServiceImpl).provider.defaultModel?.name,
        'qwen/qwen2.5-coder-14b',
      );
    });

    test('generate content with mocked successful response', () async {
      // Arrange
      final configPath = 'test/data/config/valid_config.yaml';
      final aiServiceResult = await AiServiceFactoryImpl.createAiServiceStatic(
        configRepository: configRepository,
        providerName: 'lmstudio',
        configPath: configPath,
        httpClient: mockHttpClient,
      );
      expect(aiServiceResult.isRight(), true);
      aiService = aiServiceResult.getOrElse(
        (_) => throw Exception('Failed to create AI service'),
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
      final aiServiceResult = await AiServiceFactoryImpl.createAiServiceStatic(
        configRepository: configRepository,
        providerName: 'lmstudio',
        configPath: configPath,
        httpClient: mockHttpClient,
      );
      expect(aiServiceResult.isRight(), true);
      aiService = aiServiceResult.getOrElse(
        (_) => throw Exception('Failed to create AI service'),
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
      final aiServiceResult = await AiServiceFactoryImpl.createAiServiceStatic(
        configRepository: configRepository,
        providerName: 'lmstudio',
        configPath: configPath,
        httpClient: mockHttpClient,
      );
      expect(aiServiceResult.isRight(), true);
      aiService = aiServiceResult.getOrElse(
        (_) => throw Exception('Failed to create AI service'),
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
        );

        // Create AI service
        aiService = createAiServiceImpl(
          httpClient: mockHttpClient,
          provider: provider,
        );

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
