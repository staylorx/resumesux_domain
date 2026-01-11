import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Base implementation for document repositories with common file saving logic.
class DocumentRepositoryImpl {
  Logger get logger => LoggerFactory.create('DocumentRepositoryImpl');
  final FileRepository fileRepository;

  DocumentRepositoryImpl({required this.fileRepository});

  /// Protected method to save content to a file.
  /// Subclasses should provide the appropriate file path.
  Future<Either<Failure, Unit>> saveToFile({
    required String filePath,
    required String content,
    required String documentType,
  }) async {
    try {
      final file = File(filePath);
      await file.writeAsString(content);
      logger.info('Saved $documentType to $filePath (${content.length} chars)');
      return Right(unit);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to save $documentType: $e'));
    }
  }
}
