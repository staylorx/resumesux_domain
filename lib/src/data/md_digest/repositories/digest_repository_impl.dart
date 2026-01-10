import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Implementation of the DigestRepository.
class DigestRepositoryImpl implements DigestRepository {
  final String digestPath;
  late final GigRepository gigRepository;
  late final AssetRepository assetRepository;

  DigestRepositoryImpl({
    required this.digestPath,
    required AiService aiService,
  }) {
    gigRepository = GigRepositoryImpl(
      digestPath: digestPath,
      aiService: aiService,
    );
    assetRepository = AssetRepositoryImpl(
      digestPath: digestPath,
      aiService: aiService,
    );
  }

  @override
  /// Retrieves all digests from the digest path.
  Future<Either<Failure, List<Digest>>> getAllDigests() async {
    try {
      final gigsResult = await gigRepository.getAllGigs();
      if (gigsResult.isLeft()) {
        return Left(gigsResult.getLeft().toNullable()!);
      }
      final gigs = gigsResult.getOrElse((_) => []);
      final assetsResult = await assetRepository.getAllAssets();
      if (assetsResult.isLeft()) {
        return Left(assetsResult.getLeft().toNullable()!);
      }
      final assets = assetsResult.getOrElse((_) => []);
      final digest = Digest(gigs: gigs, assets: assets);
      return Right([digest]);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to get digest: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveGigAiResponse({
    required String filePath,
  }) async {
    return gigRepository.saveAiResponse(filePath: filePath);
  }

  @override
  Future<Either<Failure, Unit>> saveAssetAiResponse({
    required String filePath,
  }) async {
    return assetRepository.saveAiResponse(filePath: filePath);
  }
}
