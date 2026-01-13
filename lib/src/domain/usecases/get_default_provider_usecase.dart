import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';

import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for retrieving the default AI provider from configuration.
class GetDefaultProviderUsecase with Loggable {
  final ConfigRepository configRepository;

  /// Creates a new instance of [GetDefaultProviderUsecase].
  GetDefaultProviderUsecase({Logger? logger, required this.configRepository}) {
    this.logger = logger;
  }

  /// Retrieves the default AI provider from the configuration.
  ///
  /// Parameters:
  /// - [configPath]: Optional path to the config file. If null, uses default.
  ///
  /// Returns: [Either<Failure, AiProvider>] containing the default provider or a failure.
  Future<Either<Failure, AiProvider>> call({String? configPath}) async {
    logger?.info(
      '[GetDefaultProviderUsecase] Retrieving default provider from config path: ${configPath ?? 'default'}',
    );
    final result = await configRepository.getDefaultProvider(
      configPath: configPath,
    );
    result.fold(
      (failure) => logger?.error(
        '[GetDefaultProviderUsecase] Failed to retrieve default provider: ${failure.message}',
      ),
      (provider) => logger?.info(
        '[GetDefaultProviderUsecase] Default provider retrieved successfully: ${provider.name}',
      ),
    );
    return result;
  }
}
