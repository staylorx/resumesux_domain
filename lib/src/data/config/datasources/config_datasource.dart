import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:yaml/yaml.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// A datasource for loading configuration files.
class ConfigDatasource {
  /// Loads a configuration file from the given file path.
  Future<Either<Failure, Map<String, dynamic>>> loadConfigFile(
    String filePath,
  ) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return Left(
          NotFoundFailure(message: 'Config file not found: $filePath'),
        );
      }

      final content = await file.readAsString();
      final yamlMap = loadYaml(content);

      if (yamlMap is! Map) {
        return Left(
          ParsingFailure(
            message: 'Config file must contain a YAML map at root level',
          ),
        );
      }

      // Convert YamlMap to regular Map for easier handling
      final configMap = _convertYamlMapToMap(yamlMap);
      return Right(configMap);
    } on YamlException catch (e) {
      return Left(ParsingFailure(message: 'Invalid YAML syntax: ${e.message}'));
    } catch (e) {
      return Left(ParsingFailure(message: 'Failed to load config file: $e'));
    }
  }

  Map<String, dynamic> _convertYamlMapToMap(dynamic yamlMap) {
    if (yamlMap is Map) {
      final result = <String, dynamic>{};
      for (final entry in yamlMap.entries) {
        final key = entry.key.toString();
        final value = entry.value;
        if (value is Map) {
          result[key] = _convertYamlMapToMap(value);
        } else if (value is List) {
          result[key] = value.map((item) {
            return item is Map ? _convertYamlMapToMap(item) : item;
          }).toList();
        } else {
          result[key] = value;
        }
      }
      return result;
    }
    return {};
  }
}
