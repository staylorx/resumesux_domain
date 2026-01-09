import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:resume_suckage_domain/resume_suckage_domain.dart';

/// Implementation of the JobReqRepository.
class JobReqRepositoryImpl implements JobReqRepository {
  @override
  /// Retrieves a job requirement from the given path.
  Future<Either<Failure, JobReq>> getJobReq({required String path}) async {
    try {
      final file = File(path);
      if (!file.existsSync()) {
        return Left(NotFoundFailure(message: 'Job req file not found: $path'));
      }

      final content = await file.readAsString();
      final jobReq = _parseJobReq(content: content);
      if (jobReq == null) {
        return Left(ParsingFailure(message: 'Failed to parse job req: $path'));
      }

      return Right(jobReq);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to read job req: $e'));
    }
  }

  @override
  /// Marks the job requirement as processed.
  Future<Either<Failure, Unit>> markAsProcessed({required String id}) async {
    // For now, just return success. In a real implementation,
    // you'd need to find the file by ID and update its frontmatter.
    // This would require maintaining a mapping of IDs to file paths.
    return Right(unit);
  }

  @override
  /// Updates the frontmatter of the job requirement file.
  Future<Either<Failure, Unit>> updateFrontmatter({
    required String path,
    required JobReq jobReq,
  }) async {
    try {
      final file = File(path);
      final content = await file.readAsString();

      // Parse existing bullets if present
      Map<String, dynamic> existingFields = {};
      String cleanContent = content;
      final lines = content.split('\n');
      int bodyStartIndex = 0;
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.startsWith('- ') || line.startsWith('* ')) {
          final bullet = line.substring(2);
          final colonIndex = bullet.indexOf(':');
          if (colonIndex != -1) {
            final key = bullet.substring(0, colonIndex).trim().toLowerCase();
            final value = bullet.substring(colonIndex + 1).trim();
            existingFields[key] = value;
          }
        } else if (line.trim().isEmpty) {
          continue;
        } else {
          bodyStartIndex = i;
          break;
        }
      }
      cleanContent = lines.sublist(bodyStartIndex).join('\n').trim();

      // Update JobReq-specific fields
      existingFields['job req id'] = jobReq.id;
      existingFields['job title'] = jobReq.title;
      existingFields['processed'] = jobReq.processed.toString();
      existingFields['created date'] =
          jobReq.createdDate?.toIso8601String().split('T').first ?? '';
      existingFields['where found'] = jobReq.whereFound ?? '';

      // Build bullets from merged fields
      final bulletLines = existingFields.entries.map((entry) {
        return '- ${entry.key}: ${entry.value}';
      }).toList();

      final bullets = bulletLines.join('\n');
      final fullContent = '$bullets\n\n$cleanContent';

      await file.writeAsString(fullContent);

      return Right(unit);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to update frontmatter: $e'));
    }
  }

  JobReq? _parseJobReq({required String content}) {
    try {
      final lines = content.split('\n');
      if (lines.isEmpty ||
          (!lines[0].startsWith('- ') && !lines[0].startsWith('* '))) {
        return null;
      }

      final bulletLines = <String>[];
      int bodyStartIndex = 0;

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.startsWith('- ') || line.startsWith('* ')) {
          bulletLines.add(line.substring(2)); // Remove bullet prefix
        } else if (line.trim().isEmpty) {
          continue;
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

      final actualContent = lines.sublist(bodyStartIndex).join('\n').trim();

      return JobReq(
        id: fields['job req id'] ?? '',
        title: fields['job title'] ?? '',
        content: actualContent,
        processed: fields['processed']?.toLowerCase() == 'true',
        createdDate: fields['created date'] != null
            ? DateTime.tryParse(fields['created date']!)
            : null,
        whereFound: fields['where found'],
      );
    } catch (e) {
      return null;
    }
  }
}
