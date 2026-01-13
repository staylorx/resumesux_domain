import 'package:resumesux_domain/src/data/data.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Factory for creating ApplicationDatasource
ApplicationDatasource createApplicationDatasource({
  required DatabaseService dbService,
}) =>
    ApplicationDatasource(dbService: dbService);