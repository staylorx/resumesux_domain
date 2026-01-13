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
      final service = await AiServiceImpl.create(
        logger: logger,
        configRepository: configRepository,
        providerName: providerName,
        configPath: configPath,
        httpClient: httpClient,
      );
      return Right(service);
    } catch (e) {
      logger?.error('[AiServiceFactoryImpl] Failed to create AI service: $e');
      return Left(ServiceFailure(message: 'Failed to create AI service: $e'));
    }
  }
}
