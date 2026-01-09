import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:resumesux_domain/resumesux_domain.dart';

/// Implementation of the JobReqRepository.
class JobReqRepositoryImpl implements JobReqRepository {
  final JobReqDatasource jobReqDatasource;

  JobReqRepositoryImpl({required this.jobReqDatasource});
  @override
  /// Updates an existing job requirement.
  Future<Either<Failure, Unit>> updateJobReq({required JobReq jobReq}) async {
    return await jobReqDatasource.updateJobReq(jobReq: jobReq);
  }

  @override
  /// Retrieves a job requirement from the given path.
  Future<Either<Failure, JobReq>> getJobReq({required String path}) async {
    try {
      final file = File(path);
      if (!file.existsSync()) {
        return Left(NotFoundFailure(message: 'Job req file not found: $path'));
      }

      final content = await file.readAsString();

      // Validate content
      if (content.trim().startsWith('---')) {
        return Left(
          ValidationFailure(
            message: 'YAML frontmatter not supported in job req files',
          ),
        );
      }
      if (content.trim().isEmpty) {
        return Left(ValidationFailure(message: 'Job req content is empty'));
      }
      try {
        md.markdownToHtml(content);
      } catch (e) {
        return Left(ValidationFailure(message: 'Invalid Markdown syntax: $e'));
      }

      final jobReq = _parseJobReq(content: content);
      if (jobReq == null) {
        return Left(ParsingFailure(message: 'Failed to parse job req: $path'));
      }

      return Right(jobReq);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to read job req: $e'));
    }
  }

  JobReq? _parseJobReq({required String content}) {
    try {
      final lines = content.split('\n');
      if (lines.isEmpty) return null;

      String bodyContent;
      Map<String, dynamic> fields = {};

      if (lines[0].startsWith('- ') || lines[0].startsWith('* ')) {
        // Bullet format
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

        for (final bullet in bulletLines) {
          final colonIndex = bullet.indexOf(':');
          if (colonIndex != -1) {
            final key = bullet.substring(0, colonIndex).trim().toLowerCase();
            final value = bullet.substring(colonIndex + 1).trim();
            fields[key] = value;
          }
        }

        bodyContent = lines.sublist(bodyStartIndex).join('\n').trim();
      } else {
        bodyContent = content;
      }

      return JobReq(
        id: (fields['job req id'] ?? fields['id'] ?? '').toString(),
        title: (fields['job title'] ?? fields['title'] ?? '').toString(),
        content: bodyContent,
        salary: fields['salary']?.toString(),
        location: fields['location']?.toString(),
        concern: fields['concern'] != null
            ? Concern(
                name: fields['concern'].toString(),
                location: fields['location']?.toString(),
              )
            : null,
        state: (fields['state'] ?? 'raw').toString(),
        createdDate: fields['created date'] != null
            ? DateTime.tryParse(fields['created date'].toString())
            : fields['posted'] != null
            ? DateTime.tryParse(fields['posted'].toString())
            : null,
        whereFound: (fields['where found'] ?? fields['company'] ?? '')
            .toString(),
      );
    } catch (e) {
      return null;
    }
  }
}
