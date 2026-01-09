import 'package:fpdart/fpdart.dart';
import 'package:resume_suckage_domain/resume_suckage_domain.dart';

/// Use case for loading application configuration.
class GetConfigUsecase {
  final ConfigRepository configRepository;

  /// Creates a new instance of [GetConfigUsecase].
  GetConfigUsecase({required this.configRepository});

  /// Loads the configuration from the specified path or default.
  ///
  /// Parameters:
  /// - [configPath]: Optional path to the config file. If null, uses default.
  ///
  /// Returns: [Either<Failure, Config>] containing the loaded configuration or a failure.
  Future<Either<Failure, Config>> call({String? configPath}) async {
    logger.info(
      '[GetConfigUsecase] Loading configuration from path: ${configPath ?? 'default'}',
    );
    final result = await configRepository.loadConfig(configPath: configPath);
    result.fold(
      (failure) => logger.severe(
        '[GetConfigUsecase] Failed to load config: ${failure.message}',
      ),
      (config) =>
          logger.info('[GetConfigUsecase] Configuration loaded successfully'),
    );
    return result;
  }
}
