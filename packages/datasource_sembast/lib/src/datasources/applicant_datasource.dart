import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

import '../models/applicant_dto.dart';

/// Datasource for persisting applicant data.
class ApplicantDatasource {
  final DatabaseService _dbService;
  bool _initialized = false;

  /// Creates a datasource with required DatabaseService.
  ApplicantDatasource({required DatabaseService dbService})
    : _dbService = dbService;

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await _dbService.initialize();
      _initialized = true;
    }
  }

  /// Saves an applicant DTO to the store.
  Future<Either<Failure, Unit>> saveApplicant(ApplicantDto dto) async {
    try {
      await _ensureInitialized();
      await _dbService.put(
        storeName: 'applicants',
        key: dto.id,
        value: dto.toMap(),
      );
      return Right(unit);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to save applicant: $e'));
    }
  }

  /// Retrieves an applicant by ID.
  Future<Either<Failure, ApplicantDto>> getApplicant(String id) async {
    try {
      await _ensureInitialized();
      final data = await _dbService.get(storeName: 'applicants', key: id);
      if (data == null) {
        return Left(NotFoundFailure(message: 'Applicant not found: $id'));
      }
      return Right(ApplicantDto.fromMap(data));
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to get applicant: $e'));
    }
  }

  /// Retrieves all applicants.
  Future<Either<Failure, List<ApplicantDto>>> getAllApplicants() async {
    try {
      await _ensureInitialized();
      final records = await _dbService.find(storeName: 'applicants');
      final applicants = records
          .map((record) => ApplicantDto.fromMap(record))
          .toList();
      return Right(applicants);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to get all applicants: $e'));
    }
  }

  /// Deletes an applicant by ID.
  Future<Either<Failure, Unit>> deleteApplicant(String id) async {
    try {
      await _ensureInitialized();
      await _dbService.delete(storeName: 'applicants', key: id);
      return Right(unit);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to delete applicant: $e'));
    }
  }
}
