import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Repository for configuration-related operations.
abstract class ConfigRepository {
  /// Loads the configuration.
  Future<Either<Failure, Config>> loadConfig({String? configPath});

  /// Gets the provider by name.
  Future<Either<Failure, AiProvider>> getProvider({
    required String providerName,
    String? configPath,
  });

  /// Gets the default provider.
  Future<Either<Failure, AiProvider>> getDefaultProvider({String? configPath});

  /// Gets the default model from the default provider.
  Future<Either<Failure, AiModel>> getDefaultModel({String? configPath});

  /// Checks if the provider has a default model.
  bool hasDefaultModel({required AiProvider provider});
}
