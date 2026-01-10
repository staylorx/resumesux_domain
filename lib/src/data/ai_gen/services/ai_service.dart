import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Implementation of AiService for generating content using AI providers.
class AiServiceImpl implements AiService {
  final Logger logger = LoggerFactory.create('AiService');
  final http.Client httpClient;
  final AiProvider provider;

  AiServiceImpl({required this.httpClient, required this.provider});

  /// Creates an AiServiceImpl instance for the given provider.
  static Future<AiServiceImpl> create({
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
    return AiServiceImpl(httpClient: httpClient, provider: provider);
  }

  /// Generates content using the AI provider.
  @override
  Future<Either<Failure, String>> generateContent({
    required String prompt,
  }) async {
    logger.fine('[AiService] Using default model: ${provider.defaultModel}');
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
        logger.info(
          '[AiService] AI response content length: ${content.length}',
        );
        logger.fine('[AiService] AI response content: $content');
        return Right(content);
      } else {
        logger.severe(
          '[AiService] AI API request failed: ${response.statusCode}',
        );
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
