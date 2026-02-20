import 'package:fpdart/fpdart.dart';

import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for loading application configuration.
class GetConfigUsecase with Loggable {
  final ConfigRepository configRepository;

  /// Creates a new instance of [GetConfigUsecase].
  GetConfigUsecase({Logger? logger, required this.configRepository}) {
    this.logger = logger;
  }

  /// Loads the configuration from the specified path or default.
  ///
  /// Parameters:
  /// - [configPath]: Optional path to the config file. If null, uses default.
  ///
  /// Returns: [Either<Failure, Config>] containing the loaded configuration or a failure.
  Future<Either<Failure, Config>> call({String? configPath}) async {
    logger?.info(
      '[GetConfigUsecase] Loading configuration from path: ${configPath ?? 'default'}',
    );
    final result = await configRepository.loadConfig(configPath: configPath);
    result.match(
      (failure) => logger?.error(
        '[GetConfigUsecase] Failed to load config: ${failure.message}',
      ),
      (config) =>
          logger?.info('[GetConfigUsecase] Configuration loaded successfully'),
    );
    return result;
  }
}
