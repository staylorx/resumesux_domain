import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Implementation of the DigestRepository.
class DigestRepositoryImpl implements DigestRepository {
  final String digestPath;
  final GigRepository gigRepository;

  DigestRepositoryImpl({required this.digestPath, required this.gigRepository});

  @override
  /// Retrieves all digests from the digest path.
  Future<Either<Failure, List<Digest>>> getAllDigests() async {
    try {
      final gigsResult = await gigRepository.getAllGigs();
      if (gigsResult.isLeft()) {
        return Left(gigsResult.getLeft().toNullable()!);
      }
      final gigs = gigsResult.getOrElse((_) => []);
      final assets = await _getAllAssets();
      final digest = Digest(gigs: gigs, assets: assets);
      return Right([digest]);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to get digest: $e'));
    }
  }

  Future<List<Asset>> _getAllAssets() async {
    final assetsDir = Directory('$digestPath/assets');
    if (!assetsDir.existsSync()) {
      return [];
    }

    final assets = <Asset>[];

    final files = assetsDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.md'));

    for (final file in files) {
      final content = await file.readAsString();
      final type = _getAssetType(path: file.path);
      assets.add(
        Asset(
          tags: [Tag(name: type)],
          content: content,
        ),
      );
    }

    return assets;
  }

  String _getAssetType({required String path}) {
    final parts = path.split(Platform.pathSeparator);
    final assetsIndex = parts.indexWhere((part) => part == 'assets');
    if (assetsIndex != -1 && assetsIndex + 1 < parts.length) {
      final nextPart = parts[assetsIndex + 1];
      if (nextPart.contains('.')) {
        return nextPart.split('.').first;
      } else {
        return nextPart;
      }
    }
    return 'unknown';
  }
}
