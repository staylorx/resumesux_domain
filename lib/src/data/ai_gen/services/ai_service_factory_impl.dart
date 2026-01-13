import 'package:http/http.dart' as http;
import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:resumesux_domain/resumesux_domain.dart';
import 'package:resumesux_domain/src/data/ai_gen/services/ai_service.dart';

/// Implementation of AiServiceFactory for creating AiService instances.
class AiServiceFactoryImpl with Loggable implements AiServiceFactory {
  final ConfigRepository configRepository;
  final http.Client httpClient;

  /// Creates a new instance of [AiServiceFactoryImpl].
  AiServiceFactoryImpl({
    Logger? logger,
    required this.configRepository,
    required this.httpClient,
  }) {
    this.logger = logger;
  }

  /// Creates an AI service for the specified provider.
  @override
  Future<Either<Failure, AiService>> createAiService({
    required String providerName,
    String? configPath,
  }) async {
    try {
      final providerResult = await configRepository.getProvider(
        providerName: providerName,
        configPath: configPath,
      );
      if (providerResult.isLeft()) {
        final failure = providerResult.getLeft().toNullable()!;
        logger?.error(
          '[AiServiceFactoryImpl] Failed to get provider: ${failure.message}',
        );
        return Left(failure);
      }
      final provider = providerResult.getOrElse(
        (_) => throw Exception('Unexpected error'),
      );
      final service = AiServiceImpl(
        logger: logger,
        httpClient: httpClient,
        provider: provider,
      );
      return Right(service);
    } catch (e) {
      logger?.error('[AiServiceFactoryImpl] Failed to create AI service: $e');
      return Left(ServiceFailure(message: 'Failed to create AI service: $e'));
    }
  }

  /// Static convenience method to create an AI service directly.
  ///
  /// This method creates a factory instance internally and uses it to create the service.
  /// Useful for simple use cases where dependency injection is not set up.
  static Future<Either<Failure, AiService>> createAiServiceStatic({
    Logger? logger,
    required ConfigRepository configRepository,
    required String providerName,
    String? configPath,
    required http.Client httpClient,
  }) async {
    final factory = AiServiceFactoryImpl(
      logger: logger,
      configRepository: configRepository,
      httpClient: httpClient,
    );
    return factory.createAiService(
      providerName: providerName,
      configPath: configPath,
    );
  }
}
