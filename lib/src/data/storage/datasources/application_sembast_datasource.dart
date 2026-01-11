import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

import '../../../domain/services/database_service.dart';
import '../sembast_database_service.dart';

/// Sembast datasource for persisting application data and AI responses.
class ApplicationSembastDatasource {
  late final DatabaseService _dbService;
  bool _initialized = false;
  final String? dbPath;

  /// Creates a datasource with optional dbPath. If null, uses memory database.
  ApplicationSembastDatasource({this.dbPath}) {
    _dbService = SembastDatabaseService(dbPath, 'applications.db');
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await _dbService.initialize(dbPath, 'applications.db');
      _initialized = true;
    }
  }

  /// Saves an application DTO to the store.
  Future<Either<Failure, Unit>> saveApplication(ApplicationDto dto) async {
    try {
      await _ensureInitialized();
      await _dbService.put('applications', dto.id, dto.toMap());
      return Right(unit);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to save application: $e'));
    }
  }

  /// Retrieves an application by ID.
  Future<Either<Failure, ApplicationDto>> getApplication(String id) async {
    try {
      await _ensureInitialized();
      final data = await _dbService.get('applications', id);
      if (data == null) {
        return Left(NotFoundFailure(message: 'Application not found: $id'));
      }
      return Right(ApplicationDto.fromMap(data));
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to get application: $e'));
    }
  }

  /// Retrieves all applications.
  Future<Either<Failure, List<ApplicationDto>>> getAllApplications() async {
    try {
      await _ensureInitialized();
      final records = await _dbService.find('applications');
      final applications = records
          .map((record) => ApplicationDto.fromMap(record))
          .toList();
      return Right(applications);
    } catch (e) {
      return Left(
        ServiceFailure(message: 'Failed to get all applications: $e'),
      );
    }
  }

  /// Saves an AI response document to the appropriate store based on documentType.
  Future<Either<Failure, Unit>> saveAiResponseDocument(DocumentDto dto) async {
    try {
      await _ensureInitialized();
      final storeName = _getAiResponseStoreName(dto.documentType);
      await _dbService.put(storeName, dto.id, dto.toMap());
      return Right(unit);
    } catch (e) {
      return Left(
        ServiceFailure(message: 'Failed to save AI response document: $e'),
      );
    }
  }

  /// Retrieves all AI response documents from AI response stores.
  Future<Either<Failure, List<DocumentDto>>> getAllAiResponseDocuments() async {
    try {
      await _ensureInitialized();
      final allAiResponses = <DocumentDto>[];

      final storeNames = [
        'jobreq_responses',
        'gig_responses',
        'asset_responses',
      ];

      for (final storeName in storeNames) {
        final records = await _dbService.find(storeName);
        for (final record in records) {
          allAiResponses.add(DocumentDto.fromMap(record));
        }
      }

      return Right(allAiResponses);
    } catch (e) {
      return Left(
        ServiceFailure(message: 'Failed to get all AI response documents: $e'),
      );
    }
  }

  /// Saves a document DTO to the appropriate store based on documentType.
  Future<Either<Failure, Unit>> saveDocument(DocumentDto dto) async {
    try {
      await _ensureInitialized();
      final storeName = _getDocumentStoreName(dto.documentType);
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
      final storeName = _getDocumentStoreName(documentType);
      final data = await _dbService.get(storeName, id);
      if (data == null) {
        return Left(NotFoundFailure(message: 'Document not found: $id'));
      }
      return Right(DocumentDto.fromMap(data));
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to get document: $e'));
    }
  }

  /// Retrieves all documents from document stores.
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

  String _getAiResponseStoreName(String documentType) {
    switch (documentType) {
      case 'jobreq_response':
        return 'jobreq_responses';
      case 'gig_responses':
        return 'gig_responses';
      case 'asset_responses':
        return 'asset_responses';
      default:
        throw ArgumentError('Unknown AI response document type: $documentType');
    }
  }

  String _getDocumentStoreName(String documentType) {
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
