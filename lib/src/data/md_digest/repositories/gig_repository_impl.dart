import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Implementation of the GigRepository.
class GigRepositoryImpl implements GigRepository {
  final String digestPath;

  GigRepositoryImpl({required this.digestPath});

  @override
  /// Retrieves all gigs from the digest path.
  Future<Either<Failure, List<Gig>>> getAllGigs() async {
    try {
      final gigsDir = Directory('$digestPath/gigs');
      if (!gigsDir.existsSync()) {
        return Right([]);
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

      return Right(gigs);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to read gigs: $e'));
    }
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
}
