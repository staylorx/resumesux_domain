import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Abstract service for reading files.
/// This allows the domain layer to read files without depending on dart:io.
abstract class FileReader {
  /// Reads the content of a file at the given path.
  /// Returns the file content or a failure.
  Either<Failure, String> readFile(String path);
}