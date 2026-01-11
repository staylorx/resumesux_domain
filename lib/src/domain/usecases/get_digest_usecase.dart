import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for retrieving digest data including gigs and assets.
class GetDigestUsecase {
  final Logger logger = LoggerFactory.create(name: 'GetDigestUsecase');
  final GigRepository gigRepository;
  final AssetRepository assetRepository;

  /// Creates a new instance of [GetDigestUsecase].
  GetDigestUsecase({
    required this.gigRepository,
    required this.assetRepository,
  });

  /// Retrieves all gigs and assets from the digest.
  ///
  /// Returns: [Either<Failure, ({List<Gig> gigs, List<Asset> assets})>]
  /// containing the digest data or a failure.
  Future<Either<Failure, ({List<Gig> gigs, List<Asset> assets})>> call() async {
    logger.info('[GetDigestUsecase] Retrieving digest data (gigs and assets)');
    final gigsResult = await gigRepository.getAllGigs();
    final assetsResult = await assetRepository.getAllAssets();

    final Either<Failure, ({List<Gig> gigs, List<Asset> assets})> result =
        gigsResult.fold(
          (failure) => Left(failure),
          (gigs) => assetsResult.fold(
            (failure) => Left(failure),
            (assets) => Right((gigs: gigs, assets: assets)),
          ),
        );

    result.fold(
      (failure) => logger.severe(
        '[GetDigestUsecase] Failed to retrieve digest: ${failure.message}',
      ),
      (data) => logger.info(
        '[GetDigestUsecase] Digest retrieved successfully: ${data.gigs.length} gigs, ${data.assets.length} assets',
      ),
    );

    return result;
  }
}
