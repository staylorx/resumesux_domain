import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Abstract factory for creating AiService instances.
abstract class AiServiceFactory {
  /// Creates an AI service for the specified provider.
  ///
  /// Parameters:
  /// - [providerName]: The name of the AI provider to use.
  /// - [configPath]: Optional path to the config file. If null, uses default.
  ///
  /// Returns: [Either<Failure, AiService>] containing the created AI service or a failure.
  Future<Either<Failure, AiService>> createAiService({
    required String providerName,
    String? configPath,
  });
}
