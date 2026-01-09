import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:path/path.dart' as path;
import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Sembast implementation of JobReqDatasource.
class JobReqSembastDatasource implements JobReqDatasource {
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

  @override
  Future<Either<Failure, Unit>> updateJobReq({required JobReq jobReq}) async {
    try {
      final db = await _database;
      final record = _jobReqStore.record(jobReq.id);
      final data = {
        'id': jobReq.id,
        'title': jobReq.title,
        'content': jobReq.content,
        'salary': jobReq.salary,
        'location': jobReq.location,
        'concern': jobReq.concern != null
            ? {
                'name': jobReq.concern!.name,
                'description': jobReq.concern!.description,
                'location': jobReq.concern!.location,
              }
            : null,
        'state': jobReq.state,
        'createdDate': jobReq.createdDate?.toIso8601String(),
        'whereFound': jobReq.whereFound,
      };
      await record.put(db, data);
      return Right(unit);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to update job req: $e'));
    }
  }

  /// Clears all job req records from the database.
  @override
  Future<Either<Failure, Unit>> clearDatabase() async {
    try {
      final db = await _database;
      await _jobReqStore.delete(db);
      return Right(unit);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to clear database: $e'));
    }
  }
}
