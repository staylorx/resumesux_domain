import 'package:resumesux_domain/src/data/data.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Factory for creating ConfigRepositoryImpl
ConfigRepository createConfigRepositoryImpl({
  Logger? logger,
  required ConfigDatasource configDatasource,
}) =>
    ConfigRepositoryImpl(
      logger: logger,
      configDatasource: configDatasource,
    );