import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';
import 'package:resumesux_domain/src/data/data.dart';

import 'package:resumesux_domain/src/data/models/document_dto.dart';

/// Datasource for persisting document data and AI responses.
class DocumentDatasource {
  final DatabaseService _dbService;
  bool _initialized = false;

  DocumentDatasource({required DatabaseService dbService})
    : _dbService = dbService;

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await _dbService.initialize();
      _initialized = true;
    }
  }

  /// Saves an AI response document to the appropriate store based on documentType.
  Future<Either<Failure, Unit>> saveAiResponseDocument(DocumentDto dto) async {
    try {
      await _ensureInitialized();
      final storeName = _getAiResponseStoreName(dto.documentType);
      await _dbService.put(
        storeName: storeName,
        key: dto.id,
        value: dto.toMap(),
      );
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
        final records = await _dbService.find(storeName: storeName);
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
      await _dbService.put(
        storeName: storeName,
        key: dto.id,
        value: dto.toMap(),
      );
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
      final data = await _dbService.get(storeName: storeName, key: id);
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
        final records = await _dbService.find(storeName: storeName);
        for (final record in records) {
          allDocuments.add(DocumentDto.fromMap(record));
        }
      }

      return Right(allDocuments);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to get all documents: $e'));
    }
  }

  String _getAiResponseStoreName(String documentType) {
    switch (documentType) {
      case 'jobreq_response':
        return 'jobreq_responses';
      case 'gig_response':
        return 'gig_responses';
      case 'asset_response':
        return 'asset_responses';
      case 'ai_response':
        return 'jobreq_responses';
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
