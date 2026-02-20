import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';
import 'package:resumesux_domain/src/data/data.dart';

/// Datasource for persisting job req data.
class JobReqDatasource {
  final DatabaseService _dbService;
  bool _initialized = false;

  JobReqDatasource({required DatabaseService dbService})
    : _dbService = dbService;

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await _dbService.initialize();
      _initialized = true;
    }
  }

  Future<Either<Failure, List<JobReqDto>>> getAllJobReqs() async {
    try {
      await _ensureInitialized();
      final records = await _dbService.find(storeName: 'jobreqs');
      final jobReqs = records.map((record) {
        final document = DocumentDto.fromMap(record);
        final jobReqMap =
            jsonDecode(document.aiResponseJson) as Map<String, dynamic>;
        return JobReqDto.fromMap(jobReqMap);
      }).toList();
      return Right(jobReqs);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to get all job reqs: $e'));
    }
  }

  Future<Either<Failure, JobReqDto>> getJobReq(String id) async {
    try {
      await _ensureInitialized();
      final data = await _dbService.get(storeName: 'jobreqs', key: id);
      if (data == null) {
        return Left(NotFoundFailure(message: 'JobReq not found: $id'));
      }
      final document = DocumentDto.fromMap(data);
      final jobReqMap =
          jsonDecode(document.aiResponseJson) as Map<String, dynamic>;
      return Right(JobReqDto.fromMap(jobReqMap));
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to get job req: $e'));
    }
  }

  /// Deletes a job req by ID.
  Future<Either<Failure, Unit>> deleteJobReq(String id) async {
    try {
      await _ensureInitialized();
      await _dbService.delete(storeName: 'jobreqs', key: id);
      return Right(unit);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to delete job req: $e'));
    }
  }

  /// Clears all job req records from the database.
  Future<Either<Failure, Unit>> clearJobReqs() async {
    try {
      await _ensureInitialized();
      await _dbService.drop(storeName: 'jobreqs');
      return Right(unit);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to clear job reqs: $e'));
    }
  }
}
