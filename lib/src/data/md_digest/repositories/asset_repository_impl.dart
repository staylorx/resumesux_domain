import 'dart:io';
import 'package:fpdart/fpdart.dart';

import 'package:resume_suckage_domain/resume_suckage_domain.dart';

class AssetRepositoryImpl implements AssetRepository {
  final String digestPath;

  AssetRepositoryImpl({required this.digestPath});

  @override
  Future<Either<Failure, List<Asset>>> getAllAssets() async {
    try {
      final assetsDir = Directory('$digestPath/assets');
      if (!assetsDir.existsSync()) {
        return Right([]);
      }

      final assets = <Asset>[];

      // Read files in assets directory
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

      return Right(assets);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to read assets: $e'));
    }
  }

  String _getAssetType({required String path}) {
    final parts = path.split(Platform.pathSeparator);
    final assetsIndex = parts.indexWhere((part) => part == 'assets');
    if (assetsIndex != -1 && assetsIndex + 1 < parts.length) {
      final nextPart = parts[assetsIndex + 1];
      if (nextPart.contains('.')) {
        // It's a file, get the name without extension
        return nextPart.split('.').first;
      } else {
        // It's a subdirectory
        return nextPart;
      }
    }
    return 'unknown';
  }
}
