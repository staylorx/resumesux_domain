import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:path/path.dart' as path;
import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:resumesux_domain/src/domain/failure.dart';
import '../../models/job_req_dto.dart';

/// Sembast implementation of JobReqDatasource.
class JobReqSembastDatasource {
  Database? _db;
  final StoreRef<String, Map<String, dynamic>> _jobReqStore =
      stringMapStoreFactory.store('jobReqs');

  final String? dbPath;

  /// Creates a datasource with optional dbPath. If null, uses memory database.
  JobReqSembastDatasource({this.dbPath});

  Future<Database> get _database async {
    if (_db != null) return _db!;
    if (dbPath != null) {
      final dbPathFull = path.join(Directory.current.path, dbPath!);
      await Directory(path.dirname(dbPathFull)).create(recursive: true);
      _db = await databaseFactoryIo.openDatabase(dbPathFull);
    } else {
      _db = await databaseFactoryMemory.openDatabase('jobReqs.db');
    }
    return _db!;
  }

  Future<Either<Failure, JobReqDto>> createJobReq({
    required JobReqDto jobReqDto,
  }) async {
    try {
      final db = await _database;
      final record = _jobReqStore.record(jobReqDto.id);
      final data = jobReqDto.toMap();
      await record.put(db, data);
      return Right(jobReqDto);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to create job req: $e'));
    }
  }

  Future<Either<Failure, JobReqDto>> getJobReq({required String id}) async {
    try {
      final db = await _database;
      final record = _jobReqStore.record(id);
      final data = await record.get(db);
      if (data == null) {
        return Left(NotFoundFailure(message: 'Job req not found: $id'));
      }
      final jobReqDto = JobReqDto.fromMap(data);
      return Right(jobReqDto);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to get job req: $e'));
    }
  }

  Future<Either<Failure, Unit>> updateJobReq({
    required JobReqDto jobReqDto,
  }) async {
    try {
      final db = await _database;
      final record = _jobReqStore.record(jobReqDto.id);
      final data = jobReqDto.toMap();
      await record.put(db, data);
      return Right(unit);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to update job req: $e'));
    }
  }

  /// Clears all job req records from the database.
  Future<Either<Failure, Unit>> clearDatabase() async {
    try {
      final db = await _database;
      await _jobReqStore.drop(db);
      return Right(unit);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to clear database: $e'));
    }
  }
}
