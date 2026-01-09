import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';
import 'package:resume_suckage_domain/resume_suckage_domain.dart';

// TODO: is there any other data returned from the result, for instance, how much
// it cost to run the request, etc.? Even if we had token counts in and out,
// we could estimate costs.

/// Service for generating content using AI providers.
class AiService {
  final Logger logger = LoggerFactory.create('AiService');
  final http.Client httpClient;
  final AiProvider provider;

  AiService({required this.httpClient, required this.provider});

  /// Creates an AiService instance for the given provider.
  static Future<AiService> create({
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
    return AiService(httpClient: httpClient, provider: provider);
  }

  /// Generates content using the AI provider.
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
        logger.fine(
          '[AiService] AI response content length: ${content.length}',
        );
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
