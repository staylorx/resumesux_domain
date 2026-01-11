import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

import '../../../domain/services/database_service.dart';
import '../sembast_database_service.dart';

/// Sembast datasource for persisting document data.
class DocumentSembastDatasource {
  late final DatabaseService _dbService;
  bool _initialized = false;
  final String? dbPath;

  /// Creates a datasource with optional dbPath. If null, uses memory database.
  DocumentSembastDatasource({this.dbPath}) {
    _dbService = SembastDatabaseService(dbPath, 'documents.db');
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await _dbService.initialize(dbPath, 'documents.db');
      _initialized = true;
    }
  }

  /// Saves a document DTO to the appropriate store based on documentType.
  Future<Either<Failure, Unit>> saveDocument(DocumentDto dto) async {
    try {
      await _ensureInitialized();
      final storeName = _getStoreName(dto.documentType);
      await _dbService.put(storeName, dto.id, dto.toMap());
      return Right(unit);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to save document: $e'));
    }
  }

  /// Retrieves a document by ID and type.
  Future<Either<Failure, DocumentDto>> getDocument(
    String id,
    String documentType,
  ) async {
    try {
      await _ensureInitialized();
      final storeName = _getStoreName(documentType);
      final data = await _dbService.get(storeName, id);
      if (data == null) {
        return Left(NotFoundFailure(message: 'Document not found: $id'));
      }
      return Right(DocumentDto.fromMap(data));
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to get document: $e'));
    }
  }

  /// Retrieves all documents from all stores.
  Future<Either<Failure, List<DocumentDto>>> getAllDocuments() async {
    try {
      await _ensureInitialized();
      final allDocuments = <DocumentDto>[];

      final storeNames = ['resumes', 'cover_letters', 'feedbacks', 'jobreqs'];

      for (final storeName in storeNames) {
        final records = await _dbService.find(storeName);
        for (final record in records) {
          allDocuments.add(DocumentDto.fromMap(record));
        }
      }

      return Right(allDocuments);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to get all documents: $e'));
    }
  }

  /// Clears all job req records from the database.
  Future<Either<Failure, Unit>> clearJobReqs() async {
    try {
      await _ensureInitialized();
      await _dbService.drop('jobreqs');
      return Right(unit);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to clear job reqs: $e'));
    }
  }

  String _getStoreName(String documentType) {
    switch (documentType) {
      case 'resume':
        return 'resumes';
      case 'cover_letter':
        return 'cover_letters';
      case 'feedback':
        return 'feedbacks';
      case 'jobreq':
        return 'jobreqs';
      default:
        throw ArgumentError('Unknown document type: $documentType');
    }
  }
}
