import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:resume_suckage_domain/resume_suckage_domain.dart';

/// Implementation of the DigestRepository.
class DigestRepositoryImpl implements DigestRepository {
  final String digestPath;

  DigestRepositoryImpl({required this.digestPath});

  @override
  /// Retrieves all digests from the digest path.
  Future<Either<Failure, List<Digest>>> getAllDigests() async {
    try {
      final gigs = await _getAllGigs();
      final assets = await _getAllAssets();
      final digest = Digest(gigs: gigs, assets: assets);
      return Right([digest]);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to get digest: $e'));
    }
  }

  Future<List<Gig>> _getAllGigs() async {
    final gigsDir = Directory('$digestPath/gigs');
    if (!gigsDir.existsSync()) {
      return [];
    }

    final gigs = <Gig>[];
    final files = gigsDir.listSync().whereType<File>().where(
      (file) => file.path.endsWith('.md'),
    );

    for (final file in files) {
      final content = await file.readAsString();
      final gig = _parseGig(content: content);
      if (gig != null) {
        gigs.add(gig);
      }
    }

    return gigs;
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

  Gig? _parseGig({required String content}) {
    try {
      final lines = content.split('\n');
      if (lines.isEmpty || !lines[0].startsWith('- ')) {
        return null;
      }

      final bulletLines = <String>[];
      int bodyStartIndex = 0;

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.startsWith('- ')) {
          bulletLines.add(line.substring(2)); // Remove '- ' prefix
        } else {
          bodyStartIndex = i;
          break;
        }
      }

      if (bulletLines.isEmpty) return null;

      final fields = <String, String>{};
      for (final bullet in bulletLines) {
        final colonIndex = bullet.indexOf(':');
        if (colonIndex != -1) {
          final key = bullet.substring(0, colonIndex).trim().toLowerCase();
          final value = bullet.substring(colonIndex + 1).trim();
          fields[key] = value;
        }
      }

      final body = lines.sublist(bodyStartIndex).join('\n').trim();

      return Gig(
        concern: fields['concern'] ?? '',
        location: fields['location'] ?? '',
        title: fields['title'] ?? '',
        dates: fields['dates'] ?? '',
        achievements: body,
      );
    } catch (e) {
      return null;
    }
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
