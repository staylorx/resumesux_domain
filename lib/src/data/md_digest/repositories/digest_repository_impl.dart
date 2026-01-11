import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Implementation of the DigestRepository.
class DigestRepositoryImpl implements DigestRepository {
  final String digestPath;
  @override
  late final GigRepository gigRepository;
  @override
  late final AssetRepository assetRepository;

  DigestRepositoryImpl({
    required this.digestPath,
    required AiService aiService,
    required DocumentSembastDatasource documentSembastDatasource,
    required ApplicationSembastDatasource applicationSembastDatasource,
  }) {
    gigRepository = GigRepositoryImpl(
      digestPath: digestPath,
      aiService: aiService,
      documentSembastDatasource: documentSembastDatasource,
      applicationSembastDatasource: applicationSembastDatasource,
    );
    assetRepository = AssetRepositoryImpl(
      digestPath: digestPath,
      aiService: aiService,
      documentSembastDatasource: documentSembastDatasource,
      applicationSembastDatasource: applicationSembastDatasource,
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
    required String aiResponseJson,
    required String jobReqId,
  }) async {
    return gigRepository.saveAiResponse(
      aiResponseJson: aiResponseJson,
      jobReqId: jobReqId,
    );
  }

  @override
  Future<Either<Failure, Unit>> saveAssetAiResponse({
    required String aiResponseJson,
    required String jobReqId,
  }) async {
    return assetRepository.saveAiResponse(
      aiResponseJson: aiResponseJson,
      jobReqId: jobReqId,
    );
  }
}
