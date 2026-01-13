import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';
import 'package:resumesux_domain/src/data/data.dart';
import '../../models/applicant_dto.dart';
import 'applicant_datasource.dart';
import 'asset_datasource.dart';
import 'document_datasource.dart';
import 'gig_datasource.dart';
import 'job_req_datasource.dart';

/// Datasource for persisting application data and related entities.
class ApplicationDatasource {
  final DatabaseService _dbService;

  late final ApplicantDatasource _applicantDatasource;
  late final DocumentDatasource _documentDatasource;
  late final GigDatasource _gigDatasource;
  late final AssetDatasource _assetDatasource;
  late final JobReqDatasource _jobReqDatasource;

  /// Creates a datasource with required DatabaseService.
  ApplicationDatasource({required DatabaseService dbService})
    : _dbService = dbService {
    _applicantDatasource = ApplicantDatasource(dbService: dbService);
    _documentDatasource = DocumentDatasource(dbService: dbService);
    _gigDatasource = GigDatasource(dbService: dbService);
    _assetDatasource = AssetDatasource(dbService: dbService);
    _jobReqDatasource = JobReqDatasource(dbService: dbService);
  }

  /// Saves an application DTO to the store.
  Future<Either<Failure, Unit>> saveApplication(ApplicationDto dto) async {
    try {
      await _dbService.initialize();
      await _dbService.put(
        storeName: 'applications',
        key: dto.id,
        value: dto.toMap(),
      );
      return Right(unit);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to save application: $e'));
    }
  }

  /// Retrieves an application by ID.
  Future<Either<Failure, ApplicationDto>> getApplication(String id) async {
    try {
      await _dbService.initialize();
      final data = await _dbService.get(storeName: 'applications', key: id);
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
      await _dbService.initialize();
      final records = await _dbService.find(storeName: 'applications');
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

  /// Saves an applicant DTO to the store.
  Future<Either<Failure, Unit>> saveApplicant(ApplicantDto dto) =>
      _applicantDatasource.saveApplicant(dto);

  /// Retrieves an applicant by ID.
  Future<Either<Failure, ApplicantDto>> getApplicant(String id) =>
      _applicantDatasource.getApplicant(id);

  /// Retrieves all applicants.
  Future<Either<Failure, List<ApplicantDto>>> getAllApplicants() =>
      _applicantDatasource.getAllApplicants();

  /// Deletes an applicant by ID.
  Future<Either<Failure, Unit>> deleteApplicant(String id) =>
      _applicantDatasource.deleteApplicant(id);

  /// Saves an AI response document to the appropriate store based on documentType.
  Future<Either<Failure, Unit>> saveAiResponseDocument(DocumentDto dto) =>
      _documentDatasource.saveAiResponseDocument(dto);

  /// Retrieves all AI response documents from AI response stores.
  Future<Either<Failure, List<DocumentDto>>> getAllAiResponseDocuments() =>
      _documentDatasource.getAllAiResponseDocuments();

  /// Saves a document DTO to the appropriate store based on documentType.
  Future<Either<Failure, Unit>> saveDocument(DocumentDto dto) =>
      _documentDatasource.saveDocument(dto);

  /// Retrieves a document by ID and type.
  Future<Either<Failure, DocumentDto>> getDocument(
    String id,
    String documentType,
  ) => _documentDatasource.getDocument(id, documentType);

  /// Retrieves all documents from document stores.
  Future<Either<Failure, List<DocumentDto>>> getAllDocuments() =>
      _documentDatasource.getAllDocuments();

  /// Saves a gig DTO to the store.
  Future<Either<Failure, Unit>> saveGig(GigDto dto) =>
      _gigDatasource.saveGig(dto);

  /// Retrieves a gig by ID.
  Future<Either<Failure, GigDto>> getGig(String id) =>
      _gigDatasource.getGig(id);

  /// Retrieves all gigs from the datastore.
  Future<Either<Failure, List<GigDto>>> getAllPersistedGigs() =>
      _gigDatasource.getAllPersistedGigs();

  /// Removes a gig by ID.
  Future<Either<Failure, Unit>> removeGig(String id) =>
      _gigDatasource.removeGig(id);

  /// Saves an asset DTO to the store.
  Future<Either<Failure, Unit>> saveAsset(AssetDto dto) =>
      _assetDatasource.saveAsset(dto);

  /// Retrieves an asset by ID.
  Future<Either<Failure, AssetDto>> getAsset(String id) =>
      _assetDatasource.getAsset(id);

  /// Retrieves all assets from the datastore.
  Future<Either<Failure, List<AssetDto>>> getAllPersistedAssets() =>
      _assetDatasource.getAllPersistedAssets();

  /// Removes an asset by ID.
  Future<Either<Failure, Unit>> removeAsset(String id) =>
      _assetDatasource.removeAsset(id);

  Future<Either<Failure, List<JobReqDto>>> getAllJobReqs() =>
      _jobReqDatasource.getAllJobReqs();

  Future<Either<Failure, JobReqDto>> getJobReq(String id) =>
      _jobReqDatasource.getJobReq(id);

  /// Deletes a job req by ID.
  Future<Either<Failure, Unit>> deleteJobReq(String id) =>
      _jobReqDatasource.deleteJobReq(id);

  /// Clears all job req records from the database.
  Future<Either<Failure, Unit>> clearJobReqs() =>
      _jobReqDatasource.clearJobReqs();
}
