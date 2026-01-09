import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:json_schema/json_schema.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import 'package:resumesux_domain/resumesux_domain.dart';

// Odd name for now
const String kAppName = 'resumesux';

class ConfigRepositoryImpl implements ConfigRepository {
  final Logger logger = LoggerFactory.create('ConfigRepositoryImpl');
  final ConfigDatasource configDatasource;

  ConfigRepositoryImpl({required this.configDatasource});

  Either<Failure, String> _getConfigDir(String appName) {
    final homeEnv = Platform.isWindows ? 'USERPROFILE' : 'HOME';
    final home = Platform.environment[homeEnv];
    if (home == null) {
      return Left(
        EnvironmentFailure(message: '$homeEnv environment variable not set'),
      );
    }

    // Priority 1: HOME/resumesux/config.yaml
    final homeConfigDir = p.join(home, appName);
    if (File(p.join(homeConfigDir, 'config.yaml')).existsSync()) {
      return Right(homeConfigDir);
    }

    if (Platform.isMacOS || Platform.isLinux) {
      // Priority 2: XDG_CONFIG_HOME/appName/config.yaml
      var configDir = Platform.environment['XDG_CONFIG_HOME'];
      if (configDir != null && configDir.isNotEmpty) {
        final xdgDir = p.join(configDir, appName);
        if (File(p.join(xdgDir, 'config.yaml')).existsSync()) {
          return Right(xdgDir);
        }
      }
      // Priority 3: HOME/.config/appName/config.yaml
      final dotConfigDir = p.join(home, '.config', appName);
      if (File(p.join(dotConfigDir, 'config.yaml')).existsSync()) {
        return Right(dotConfigDir);
      }
    } else if (Platform.isWindows) {
      // Priority 2: LOCALAPPDATA/resumesux/config.yaml
      final localAppData = Platform.environment['LOCALAPPDATA'];
      if (localAppData != null) {
        final localDir = p.join(localAppData, appName);
        if (File(p.join(localDir, 'config.yaml')).existsSync()) {
          return Right(localDir);
        }
      }
      // Priority 3: APPDATA/resumesux/config.yaml
      final appData = Platform.environment['APPDATA'];
      if (appData != null) {
        final appDir = p.join(appData, appName);
        if (File(p.join(appDir, 'config.yaml')).existsSync()) {
          return Right(appDir);
        }
      }
      // Existing fallback: USERPROFILE/.config/appName/config.yaml
      final fallbackDir = p.join(home, '.config', appName);
      if (File(p.join(fallbackDir, 'config.yaml')).existsSync()) {
        return Right(fallbackDir);
      }
    } else {
      return Left(
        PlatformFailure(
          message: 'Unsupported platform: ${Platform.operatingSystem}',
        ),
      );
    }

    // If no config file found in any location
    return Left(
      EnvironmentFailure(
        message: 'Config file not found in any standard location',
      ),
    );
  }

  @override
  Future<Either<Failure, Config>> loadConfig({String? configPath}) async {
    // Determine config file path
    final configFilePathResult = await _resolveConfigPath(configPath);
    if (configFilePathResult.isLeft()) {
      return Left(configFilePathResult.getLeft().toNullable()!);
    }

    final configFilePath = configFilePathResult.getOrElse((_) => '');

    // Load and parse config file
    final configResult = await configDatasource.loadConfigFile(configFilePath);
    if (configResult.isLeft()) {
      return Left(configResult.getLeft().toNullable()!);
    }

    final configMap = configResult.getOrElse((_) => {});

    // Validate and parse config structure
    final validationResult = _validateAndParseConfig(configMap);
    return validationResult;
  }

  Future<Either<Failure, String>> _resolveConfigPath(String? configPath) async {
    if (configPath != null && configPath.isNotEmpty) {
      // Use provided config path
      return Right(configPath);
    } else {
      // Use default config directory
      final configDirResult = _getConfigDir(kAppName);
      return configDirResult.fold((failure) => Left(failure), (configDir) {
        final configFilePath = p.join(configDir, 'config.yaml');
        return Right(configFilePath);
      });
    }
  }

  /// Validates the config map against the JSON schema and collects validation issues.
  /// Returns a tuple of (errors, warnings) where errors are critical issues that prevent
  /// config loading, and warnings are non-critical issues that are logged but allow proceeding.
  (List<String>, List<String>) _validateConfigWithSchema(
    Map<String, dynamic> configMap,
  ) {
    final schema = JsonSchema.create(configSchema);
    final validationResult = schema.validate(configMap);
    final isValid = validationResult.isValid;

    final errors = <String>[];
    final warnings = <String>[];

    if (!isValid) {
      // Collect detailed validation errors
      for (final error in validationResult.errors) {
        errors.add(error.message);
      }
    }

    return (errors, warnings);
  }

  Either<Failure, Config> _validateAndParseConfig(
    Map<String, dynamic> configMap,
  ) {
    // First pass: Validate config with schema
    final (errors, warnings) = _validateConfigWithSchema(configMap);

    // Output all issues to the user
    for (final error in errors) {
      logger.severe('[ConfigRepository] Config validation error: $error');
    }
    for (final warning in warnings) {
      logger.warning('[ConfigRepository] Config validation warning: $warning');
    }

    // If there are errors, fail with ValidationFailure
    if (errors.isNotEmpty) {
      return Left(
        ValidationFailure(
          message: 'Config validation failed: ${errors.join(', ')}',
        ),
      );
    }

    // If only warnings, proceed but log them
    if (warnings.isNotEmpty) {
      logger.warning(
        '[ConfigRepository] Config validation completed with warnings',
      );
    }

    // Second pass: Parse the config (proceed since no errors)
    final configMapInner = Map<String, dynamic>.from(
      configMap['config'] as Map,
    );

    // Parse config fields with defaults
    final outputDir = configMapInner['outputDir'] as String? ?? './output';
    final includeCover = configMapInner['includeCover'] as bool? ?? true;
    final includeFeedback = configMapInner['includeFeedback'] as bool? ?? true;
    final customPrompt = configMapInner['customPrompt'] as String? ?? '';
    final appendPrompt = configMapInner['appendPrompt'] as bool? ?? false;
    final digestPath = configMapInner['digestPath'] as String? ?? 'digest';

    // Parse applicant
    final applicantMap = Map<String, dynamic>.from(
      configMapInner['applicant'] as Map,
    );
    final addressMap = Map<String, dynamic>.from(
      applicantMap['address'] as Map,
    );

    final address = Address(
      street1: addressMap['street1'] as String?,
      street2: addressMap['street2'] as String?,
      city: addressMap['city'] as String?,
      state: addressMap['state'] as String?,
      zip: addressMap['zip'] is String
          ? addressMap['zip'] as String
          : (addressMap['zip'] as num)
                .toString(), // Schema allows string or number
    );

    final applicant = Applicant(
      name: applicantMap['name'] as String,
      preferredName: applicantMap['preferred_name'] as String,
      email: applicantMap['email'] as String,
      address: address,
      phone: applicantMap['phone'] as String,
      linkedin: applicantMap['linkedin'] as String,
      github: applicantMap['github'] as String,
      portfolio: applicantMap['portfolio'] as String?,
    );

    // Parse providers
    final providersMap = Map<String, dynamic>.from(
      configMapInner['providers'] as Map,
    );
    final providers = <AiProvider>[];

    for (final entry in providersMap.entries) {
      final providerId = entry.key;
      final providerMap = Map<String, dynamic>.from(entry.value as Map);

      final isDefault = providerMap['default'] as bool? ?? false;
      final url = providerMap['url'] as String;
      final key = providerMap['key'] as String;
      final modelsData = providerMap['models'] as List;
      final settings = providerMap['settings'] as Map<String, dynamic>? ?? {};

      final tempProvider = AiProvider(
        id: providerId,
        url: url,
        key: key,
        models: [],
        defaultModel: null,
        settings: settings,
        isDefault: isDefault,
      );

      final models = <AiModel>[];
      AiModel? defaultModelObj;

      for (final modelData in modelsData) {
        final modelMap = Map<String, dynamic>.from(modelData as Map);
        final name = modelMap['name'] as String;
        final modelIsDefault = modelMap['default'] as bool? ?? false;
        final modelSettings =
            modelMap['settings'] as Map<String, dynamic>? ?? {};

        final model = AiModel(
          name: name,
          isDefault: modelIsDefault,
          settings: modelSettings,
        );

        models.add(model);
        if (modelIsDefault) {
          if (defaultModelObj != null) {
            return Left(
              ValidationFailure(
                message:
                    "Provider '$providerId' must have exactly one model with 'default: true'",
              ),
            );
          }
          defaultModelObj = model;
        }
      }

      if (defaultModelObj == null) {
        return Left(
          ValidationFailure(
            message:
                "Provider '$providerId' must have exactly one model with 'default: true'",
          ),
        );
      }

      final provider = tempProvider.copyWith(
        models: models,
        defaultModel: defaultModelObj,
      );

      providers.add(provider);
    }

    // Validate that exactly one provider is marked as default
    final defaultProviders = providers.where((p) => p.isDefault).toList();
    if (defaultProviders.length != 1) {
      return Left(
        ValidationFailure(
          message: 'Config must have exactly one provider with "default: true"',
        ),
      );
    }

    return Right(
      Config(
        outputDir: outputDir,
        includeCover: includeCover,
        includeFeedback: includeFeedback,
        customPrompt: customPrompt,
        appendPrompt: appendPrompt,
        providers: providers,
        applicant: applicant,
        digestPath: digestPath,
      ),
    );
  }

  @override
  Future<Either<Failure, AiProvider>> getProvider({
    required String providerName,
    String? configPath,
  }) async {
    final configResult = await loadConfig(configPath: configPath);
    return configResult.fold((failure) => Left(failure), (config) {
      try {
        AiProvider provider;
        if (providerName == 'default') {
          provider = config.providers.firstWhere((p) => p.isDefault);
        } else {
          provider = config.providers.firstWhere((p) => p.id == providerName);
        }
        return Right(provider);
      } catch (e) {
        return Left(
          NotFoundFailure(message: 'Provider $providerName not found'),
        );
      }
    });
  }

  @override
  Future<Either<Failure, AiProvider?>> getDefaultProvider({
    String? configPath,
  }) async {
    final configResult = await loadConfig(configPath: configPath);
    return configResult.fold((failure) => Left(failure), (config) {
      try {
        final provider = config.providers.firstWhere((p) => p.isDefault);
        return Right(provider);
      } catch (e) {
        return Right(null);
      }
    });
  }

  @override
  bool hasDefaultModel({required AiProvider provider}) {
    return provider.defaultModel != null;
  }
}
