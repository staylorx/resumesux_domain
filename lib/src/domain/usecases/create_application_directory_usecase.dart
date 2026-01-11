import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for creating an application directory.
class CreateApplicationDirectoryUsecase {
  final Logger logger = LoggerFactory.create(
    'CreateApplicationDirectoryUsecase',
  );
  final FileRepository fileRepository;

  /// Creates a new instance of [CreateApplicationDirectoryUsecase].
  CreateApplicationDirectoryUsecase({required this.fileRepository});

  /// Creates the application directory for the given base output directory and job requirement.
  ///
  /// Parameters:
  /// - [baseOutputDir]: The base output directory.
  /// - [jobReq]: The job requirement.
  ///
  /// Returns: [Either<Failure, String>] the application directory path or a failure.
  Future<Either<Failure, String>> call({
    required String baseOutputDir,
    required JobReq jobReq,
  }) async {
    logger.info('Creating application directory for job: ${jobReq.title}');

    final result = fileRepository.createApplicationDirectory(
      baseOutputDir: baseOutputDir,
      jobReq: jobReq,
    );

    result.fold(
      (failure) => logger.severe(
        'Failed to create application directory: ${failure.message}',
      ),
      (path) => logger.info('Application directory created: $path'),
    );

    return result;
  }
}
