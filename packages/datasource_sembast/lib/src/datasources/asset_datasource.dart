import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';
import 'package:resumesux_domain/src/data/data.dart';

import '../models/asset_dto.dart';

/// Datasource for persisting asset data.
class AssetDatasource {
  final DatabaseService _dbService;
  bool _initialized = false;

  AssetDatasource({required DatabaseService dbService})
    : _dbService = dbService;

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await _dbService.initialize();
      _initialized = true;
    }
  }

  /// Saves an asset DTO to the store.
  Future<Either<Failure, Unit>> saveAsset(AssetDto dto) async {
    try {
      await _ensureInitialized();
      await _dbService.put(
        storeName: 'assets',
        key: dto.id,
        value: dto.toMap(),
      );
      return Right(unit);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to save asset: $e'));
    }
  }

  /// Retrieves an asset by ID.
  Future<Either<Failure, AssetDto>> getAsset(String id) async {
    try {
      await _ensureInitialized();
      final data = await _dbService.get(storeName: 'assets', key: id);
      if (data == null) {
        return Left(NotFoundFailure(message: 'Asset not found: $id'));
      }
      return Right(AssetDto.fromMap(data));
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to get asset: $e'));
    }
  }

  /// Retrieves all assets from the datastore.
  Future<Either<Failure, List<AssetDto>>> getAllPersistedAssets() async {
    try {
      await _ensureInitialized();
      final records = await _dbService.find(storeName: 'assets');
      final assets = records.map((record) => AssetDto.fromMap(record)).toList();
      return Right(assets);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to get all assets: $e'));
    }
  }

  /// Removes an asset by ID.
  Future<Either<Failure, Unit>> removeAsset(String id) async {
    try {
      await _ensureInitialized();
      await _dbService.delete(storeName: 'assets', key: id);
      return Right(unit);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to remove asset: $e'));
    }
  }
}
