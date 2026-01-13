import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';

import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for creating an AI service instance.
class CreateAiServiceUsecase with Loggable {
  final AiServiceFactory factory;

  /// Creates a new instance of [CreateAiServiceUsecase].
  CreateAiServiceUsecase({Logger? logger, required this.factory}) {
    this.logger = logger;
  }

  /// Creates an AI service for the specified provider.
  ///
  /// Parameters:
  /// - [providerName]: The name of the AI provider to use.
  /// - [configPath]: Optional path to the config file. If null, uses default.
  ///
  /// Returns: [Either<Failure, AiService>] containing the created AI service or a failure.
  Future<Either<Failure, AiService>> call({
    required String providerName,
    String? configPath,
  }) async {
    logger?.info(
      '[CreateAiServiceUsecase] Creating AI service for provider: $providerName, config path: ${configPath ?? 'default'}',
    );
    final result = await factory.createAiService(
      providerName: providerName,
      configPath: configPath,
    );
    if (result.isLeft()) {
      logger?.error(
        '[CreateAiServiceUsecase] Failed to create AI service: ${result.getLeft().toNullable()!.message}',
      );
      return result;
    }
    logger?.info(
      '[CreateAiServiceUsecase] AI service created successfully for provider: $providerName',
    );
    return result;
  }
}
