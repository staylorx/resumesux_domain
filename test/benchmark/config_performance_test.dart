import 'package:test/test.dart';
import 'package:resumesux_domain/resumesux_domain.dart';
import 'package:logging/logging.dart';

void main() {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print(
      '${record.level.name}: ${record.loggerName}: ${record.time}: ${record.message}',
    );
  });
  final logger = LoggerFactory.create('ConfigPerformanceTest');

  late ConfigRepositoryImpl configRepository;
  late ConfigDatasource configDatasource;

  setUp(() {
    configDatasource = ConfigDatasource();
    configRepository = ConfigRepositoryImpl(configDatasource: configDatasource);
  });

  group('Config Loading Performance Benchmarks', () {
    test('config loading performance - valid config', () async {
      // Arrange
      final configPath = 'test/data/config/valid_config.yaml';
      final stopwatch = Stopwatch();

      // Act
      stopwatch.start();
      final result = await configRepository.loadConfig(configPath: configPath);
      stopwatch.stop();

      // Assert
      expect(result.isRight(), true);
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(200),
      ); // Should load in under 200ms (accounting for schema validation)
      logger.info('Config loading took: ${stopwatch.elapsedMilliseconds}ms');
    });

    test('config loading performance - minimal config', () async {
      // Arrange
      final configPath = 'test/data/config/minimal_config.yaml';
      final stopwatch = Stopwatch();

      // Act
      stopwatch.start();
      final result = await configRepository.loadConfig(configPath: configPath);
      stopwatch.stop();

      // Assert
      expect(result.isRight(), true);
      expect(stopwatch.elapsedMilliseconds, lessThan(50)); // Should load faster
      logger.info(
        'Minimal config loading took: ${stopwatch.elapsedMilliseconds}ms',
      );
    });

    test('multiple config loads performance', () async {
      // Arrange
      final configPath = 'test/data/config/valid_config.yaml';
      final iterations = 10;
      final stopwatch = Stopwatch();

      // Act
      stopwatch.start();
      for (int i = 0; i < iterations; i++) {
        final result = await configRepository.loadConfig(
          configPath: configPath,
        );
        expect(result.isRight(), true);
      }
      stopwatch.stop();

      // Assert
      final averageTime = stopwatch.elapsedMilliseconds / iterations;
      expect(averageTime, lessThan(50)); // Average should be under 50ms
      logger.info(
        'Average config loading time over $iterations runs: ${averageTime}ms',
      );
    });

    test('provider selection performance', () async {
      // Arrange
      final configPath = 'test/data/config/valid_config.yaml';
      final configResult = await configRepository.loadConfig(
        configPath: configPath,
      );
      expect(configResult.isRight(), true);

      final iterations = 100;
      final stopwatch = Stopwatch();

      // Act
      stopwatch.start();
      for (int i = 0; i < iterations; i++) {
        final result = await configRepository.getProvider(
          providerName: 'lmstudio',
          configPath: configPath,
        );
        expect(result.isRight(), true);
      }
      stopwatch.stop();

      // Assert
      final averageTime = stopwatch.elapsedMilliseconds / iterations;
      expect(averageTime, lessThan(10)); // Should be very fast
      logger.info(
        'Average provider selection time over $iterations runs: ${averageTime}ms',
      );
    });

    test('default provider retrieval performance', () async {
      // Arrange
      final configPath = 'test/data/config/valid_config.yaml';
      final iterations = 100;
      final stopwatch = Stopwatch();

      // Act
      stopwatch.start();
      for (int i = 0; i < iterations; i++) {
        final result = await configRepository.getDefaultProvider(
          configPath: configPath,
        );
        expect(result.isRight(), true);
        expect(result.getOrElse((_) => null), isNotNull);
      }
      stopwatch.stop();

      // Assert
      final averageTime = stopwatch.elapsedMilliseconds / iterations;
      expect(averageTime, lessThan(10)); // Should be very fast
      logger.info(
        'Average default provider retrieval time over $iterations runs: ${averageTime}ms',
      );
    });
  });
}
