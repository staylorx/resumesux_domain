import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';
import 'package:id_logging/id_logging.dart';

import '../../data.dart';
import '../../models/applicant_dto.dart';

/// Implementation of the ApplicantRepository.
class ApplicantRepositoryImpl with Loggable implements ApplicantRepository {
  final ConfigRepository configRepository;
  final ApplicationDatasource applicationDatasource;
  final AiService aiService;

  ApplicantRepositoryImpl({
    Logger? logger,
    required this.configRepository,
    required this.applicationDatasource,
    required this.aiService,
  }) {
    this.logger = logger;
  }

  @override
  /// Retrieves the applicant with updated gigs and assets information.
  Future<Either<Failure, Applicant>> getApplicant({
    required Applicant applicant,
  }) async {
    final id = sha256.convert(utf8.encode(applicant.email)).toString();
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

    final updatedApplicant = applicant.copyWith(gigs: gigs, assets: assets);
    return Right(updatedApplicant);
  }

  @override
  Future<Either<Failure, Unit>> saveApplicant({
    required Applicant applicant,
  }) async {
    final id = sha256.convert(utf8.encode(applicant.email)).toString();
    final gigIds = applicant.gigs
        .map((gig) => sha256.convert(utf8.encode(gig.title)).toString())
        .toList();
    final assetIds = applicant.assets
        .map((asset) => sha256.convert(utf8.encode(asset.content)).toString())
        .toList();
    final addressMap = applicant.address != null
        ? {
            'street1': applicant.address!.street1,
            'street2': applicant.address!.street2,
            'city': applicant.address!.city,
            'state': applicant.address!.state,
            'zip': applicant.address!.zip,
          }
        : null;
    final dto = ApplicantDto(
      id: id,
      name: applicant.name,
      preferredName: applicant.preferredName,
      email: applicant.email,
      address: addressMap,
      phone: applicant.phone,
      linkedin: applicant.linkedin,
      github: applicant.github,
      portfolio: applicant.portfolio,
      gigIds: gigIds,
      assetIds: assetIds,
    );
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

    // Get assets
    final assetsResult = await assetRepository.getAllAssets();
    if (assetsResult.isLeft()) {
      return Left(assetsResult.getLeft().toNullable()!);
    }
    final assets = assetsResult.getOrElse((_) => []);

    final updatedApplicant = applicant.copyWith(gigs: gigs, assets: assets);
    return Right(updatedApplicant);
  }
}
