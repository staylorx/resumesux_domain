import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';
import 'package:resumesux_domain/src/data/data.dart';

import '../models/gig_dto.dart';

/// Datasource for persisting gig data.
class GigDatasource {
  final DatabaseService _dbService;
  bool _initialized = false;

  GigDatasource({required DatabaseService dbService}) : _dbService = dbService;

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await _dbService.initialize();
      _initialized = true;
    }
  }

  /// Saves a gig DTO to the store.
  Future<Either<Failure, Unit>> saveGig(GigDto dto) async {
    try {
      await _ensureInitialized();
      await _dbService.put(storeName: 'gigs', key: dto.id, value: dto.toMap());
      return Right(unit);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to save gig: $e'));
    }
  }

  /// Retrieves a gig by ID.
  Future<Either<Failure, GigDto>> getGig(String id) async {
    try {
      await _ensureInitialized();
      final data = await _dbService.get(storeName: 'gigs', key: id);
      if (data == null) {
        return Left(NotFoundFailure(message: 'Gig not found: $id'));
      }
      return Right(GigDto.fromMap(data));
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to get gig: $e'));
    }
  }

  /// Retrieves all gigs from the datastore.
  Future<Either<Failure, List<GigDto>>> getAllPersistedGigs() async {
    try {
      await _ensureInitialized();
      final records = await _dbService.find(storeName: 'gigs');
      final gigs = records.map((record) => GigDto.fromMap(record)).toList();
      return Right(gigs);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to get all gigs: $e'));
    }
  }

  /// Removes a gig by ID.
  Future<Either<Failure, Unit>> removeGig(String id) async {
    try {
      await _ensureInitialized();
      await _dbService.delete(storeName: 'gigs', key: id);
      return Right(unit);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to remove gig: $e'));
    }
  }
}
