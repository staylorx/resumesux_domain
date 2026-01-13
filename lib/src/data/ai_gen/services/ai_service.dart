import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/src/domain/domain.dart';

/// Implementation of AiService for generating content using AI providers.
class AiServiceImpl with Loggable implements AiService {
  final http.Client httpClient;
  final AiProvider provider;

  AiServiceImpl({
    Logger? logger,
    required this.httpClient,
    required this.provider,
  }) {
    this.logger = logger;
  }

  /// Creates an AiServiceImpl instance for the given provider.
  static Future<AiServiceImpl> create({
    Logger? logger,
    required ConfigRepository configRepository,
    required String providerName,
    String? configPath,
    required http.Client httpClient,
  }) async {
    final providerResult = await configRepository.getProvider(
      providerName: providerName,
      configPath: configPath,
    );
    if (providerResult.isLeft()) {
      throw Exception(
        'Failed to get provider: ${providerResult.getLeft().toNullable()!.message}',
      );
    }
    final provider = providerResult.getOrElse(
      (_) => throw Exception('Failed to get provider'),
    );
    return AiServiceImpl(
      logger: logger,
      httpClient: httpClient,
      provider: provider,
    );
  }

  /// Generates content using the AI provider.
  @override
  Future<Either<Failure, String>> generateContent({
    required String prompt,
  }) async {
    logger?.debug('Using default model: ${provider.defaultModel}');
    try {
      final response = await httpClient.post(
        Uri.parse('${provider.url}/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${provider.key}',
        },
        body: jsonEncode({
          'model': provider.defaultModel?.name ?? 'default-model',
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': provider.settings['max_tokens'] ?? 4000,
          'temperature': provider.settings['temperature'] ?? 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        logger?.debug('AI response content length: ${content.length}');
        logger?.debug('AI response content: $content');
        return Right(content);
      } else {
        logger?.error('AI API request failed: ${response.statusCode}');
        return Left(
          ServiceFailure(
            message:
                'API request failed: ${response.statusCode} ${response.body}',
          ),
        );
      }
    } catch (e) {
      return Left(NetworkFailure(message: 'Failed to generate content: $e'));
    }
  }
}
