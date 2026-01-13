import 'package:resumesux_domain/src/data/data.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Factory for creating FileRepositoryImpl
FileRepository createFileRepositoryImpl({
  Logger? logger,
}) =>
    FileRepositoryImpl(logger: logger);