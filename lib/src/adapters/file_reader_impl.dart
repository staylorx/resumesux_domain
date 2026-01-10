import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Implementation of FileReader using dart:io.
/// This belongs in the adapters layer as it deals with framework concerns.
class FileReaderImpl implements FileReader {
  @override
  Either<Failure, String> readFile(String path) {
    try {
      final file = File(path);
      if (!file.existsSync()) {
        return Left(NotFoundFailure(message: 'File not found: $path'));
      }
      final content = file.readAsStringSync();
      return Right(content);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to read file: $e'));
    }
  }
}
