import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';
import 'package:resumesux_domain/src/data/data.dart';

import '../../models/applicant_dto.dart';

class ApplicantRepositoryImpl with Loggable implements ApplicantRepository {
  final ApplicationDatasource applicationDatasource;
  final AiService aiService;

  /// Creates a new instance of [ApplicantRepositoryImpl].
  ApplicantRepositoryImpl({
    required this.applicationDatasource,
    required this.aiService,
    Logger? logger,
  }) {
    this.logger = logger;
  }

  @override
  Future<Either<Failure, List<ApplicantWithHandle>>> getAll() async {
    final result = await applicationDatasource.getAllApplicants();
    return result.map(
      (dtos) => dtos.map((dto) {
        final handle = ApplicantHandle(dto.id);
        final applicant = dto.toDomain();
        return ApplicantWithHandle(handle: handle, applicant: applicant);
      }).toList(),
    );
  }

  @override
  /// Retrieves the applicant with updated gigs and assets information.
  Future<Either<Failure, Applicant>> getByHandle({
    required ApplicantHandle handle,
  }) async {
    final id = handle.toString();
    final applicantResult = await applicationDatasource.getApplicant(id);
    if (applicantResult.isLeft()) {
      return Left(applicantResult.getLeft().toNullable()!);
    }

    final dto = applicantResult.getOrElse(
      (_) => throw Exception('Unexpected error'),
    );

    // Load gigs
    final gigs = <Gig>[];
    for (final gigId in dto.gigIds) {
      final gigResult = await applicationDatasource.getGig(gigId);
      if (gigResult.isRight()) {
        final gigDto = gigResult.getOrElse(
          (_) => throw Exception('Unexpected error'),
        );
        gigs.add(
          Gig(
            title: gigDto.title,
            concern: gigDto.concern,
            location: gigDto.location,
            dates: gigDto.dates,
            achievements: gigDto.achievements,
          ),
        );
      }
    }

    // Load assets
    final assets = <Asset>[];
    for (final assetId in dto.assetIds) {
      final assetResult = await applicationDatasource.getAsset(assetId);
      if (assetResult.isRight()) {
        final assetDto = assetResult.getOrElse(
          (_) => throw Exception('Unexpected error'),
        );
        assets.add(Asset(content: assetDto.content));
      }
    }

    final updatedApplicant = dto.toDomain().copyWith(
      gigs: gigs,
      assets: assets,
    );
    return Right(updatedApplicant);
  }

  @override
  Future<Either<Failure, Unit>> save({
    required Applicant applicant,
    required ApplicantHandle handle,
  }) async {
    final id = handle.toString();

    // Save gigs and collect ids
    final gigIds = <String>[];
    for (final gig in applicant.gigs) {
      final gigId = 'gig_${gig.title.hashCode}_${gig.concern?.hashCode ?? ''}';
      final gigDto = GigDto(
        id: gigId,
        concern: gig.concern,
        location: gig.location,
        title: gig.title,
        dates: gig.dates,
        achievements: gig.achievements,
      );
      final saveResult = await applicationDatasource.saveGig(gigDto);
      if (saveResult.isLeft()) {
        return Left(saveResult.getLeft().toNullable()!);
      }
      gigIds.add(gigId);
    }

    // Save assets and collect ids
    final assetIds = <String>[];
    for (final asset in applicant.assets) {
      final assetId = 'asset_${asset.content.hashCode}';
      final tagNames = asset.tags.map((tag) => tag.name).toList();
      final assetDto = AssetDto(
        id: assetId,
        tagNames: tagNames,
        content: asset.content,
      );
      final saveResult = await applicationDatasource.saveAsset(assetDto);
      if (saveResult.isLeft()) {
        return Left(saveResult.getLeft().toNullable()!);
      }
      assetIds.add(assetId);
    }

    final dto = ApplicantDto.fromDomain(
      applicant,
      id,
    ).copyWith(gigIds: gigIds, assetIds: assetIds);
    return applicationDatasource.saveApplicant(dto);
  }

  @override
  Future<Either<Failure, Applicant>> importDigest({
    required Applicant applicant,
    required String digestPath,
  }) async {
    // Create gig repository for the digest path
    final gigRepository = GigRepositoryImpl(
      logger: logger,
      digestPath: digestPath,
      aiService: aiService,
      applicationDatasource: applicationDatasource,
    );

    // Create asset repository for the digest path
    final assetRepository = AssetRepositoryImpl(
      logger: logger,
      digestPath: digestPath,
      aiService: aiService,
      applicationDatasource: applicationDatasource,
    );

    // Get gigs
    final gigsResult = await gigRepository.getAllGigs();
    if (gigsResult.isLeft()) {
      return Left(gigsResult.getLeft().toNullable()!);
    }
    final gigs = gigsResult.getOrElse((_) => []);
    logger?.info('Imported ${gigs.length} gigs from digest');

    // Get assets
    final assetsResult = await assetRepository.getAllAssets();
    if (assetsResult.isLeft()) {
      return Left(assetsResult.getLeft().toNullable()!);
    }
    final assets = assetsResult.getOrElse((_) => []);
    logger?.info('Imported ${assets.length} assets from digest');

    final updatedApplicant = applicant.copyWith(gigs: gigs, assets: assets);
    return Right(updatedApplicant);
  }

  @override
  Future<Either<Failure, Unit>> remove({
    required ApplicantHandle handle,
  }) async {
    final id = handle.toString();
    return applicationDatasource.deleteApplicant(id);
  }
}
