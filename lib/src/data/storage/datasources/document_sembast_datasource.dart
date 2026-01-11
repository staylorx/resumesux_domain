import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:path/path.dart' as path;
import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Sembast datasource for persisting document data with AI responses.
class DocumentSembastDatasource {
  Database? _db;
  final StoreRef<String, Map<String, dynamic>> _resumeStore =
      stringMapStoreFactory.store('resumes');
  final StoreRef<String, Map<String, dynamic>> _coverLetterStore =
      stringMapStoreFactory.store('cover_letters');
  final StoreRef<String, Map<String, dynamic>> _feedbackStore =
      stringMapStoreFactory.store('feedbacks');
  final StoreRef<String, Map<String, dynamic>> _jobReqResponseStore =
      stringMapStoreFactory.store('jobreq_responses');
  final StoreRef<String, Map<String, dynamic>> _gigResponsesStore =
      stringMapStoreFactory.store('gig_responses');
  final StoreRef<String, Map<String, dynamic>> _assetResponsesStore =
      stringMapStoreFactory.store('asset_responses');

  final String? dbPath;

  /// Creates a datasource with optional dbPath. If null, uses memory database.
  DocumentSembastDatasource({this.dbPath});

  Future<Database> get _database async {
    if (_db != null) return _db!;
    if (dbPath != null) {
      final dbPathFull = path.join(Directory.current.path, dbPath!);
      await Directory(path.dirname(dbPathFull)).create(recursive: true);
      _db = await databaseFactoryIo.openDatabase(dbPathFull);
    } else {
      _db = await databaseFactoryMemory.openDatabase('documents.db');
    }
    return _db!;
  }

  /// Saves a document DTO to the appropriate store based on documentType.
  Future<Either<Failure, Unit>> saveDocument(DocumentDto dto) async {
    try {
      final db = await _database;
      final store = _getStore(dto.documentType);
      final record = store.record(dto.id);
      await record.put(db, dto.toMap());
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
      final db = await _database;
      final store = _getStore(documentType);
      final record = store.record(id);
      final data = await record.get(db);
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
      final db = await _database;
      final allDocuments = <DocumentDto>[];

      final stores = [
        _resumeStore,
        _coverLetterStore,
        _feedbackStore,
        _jobReqResponseStore,
        _gigResponsesStore,
        _assetResponsesStore,
      ];

      for (final store in stores) {
        final records = await store.find(db);
        for (final record in records) {
          allDocuments.add(DocumentDto.fromMap(record.value));
        }
      }

      return Right(allDocuments);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to get all documents: $e'));
    }
  }

  StoreRef<String, Map<String, dynamic>> _getStore(String documentType) {
    switch (documentType) {
      case 'resume':
        return _resumeStore;
      case 'cover_letter':
        return _coverLetterStore;
      case 'feedback':
        return _feedbackStore;
      case 'jobreq_response':
        return _jobReqResponseStore;
      case 'gig_responses':
        return _gigResponsesStore;
      case 'asset_responses':
        return _assetResponsesStore;
      default:
        throw ArgumentError('Unknown document type: $documentType');
    }
  }
}
