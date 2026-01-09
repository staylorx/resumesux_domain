import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:yaml/yaml.dart';
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

      if (content.trim().isEmpty) {
        return Left(ValidationFailure(message: 'Job req content is empty'));
      }
      try {
        md.markdownToHtml(content);
      } catch (e) {
        return Left(ValidationFailure(message: 'Invalid Markdown syntax: $e'));
      }

      return _parseJobReq(content: content);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to read job req: $e'));
    }
  }

  Either<Failure, JobReq> _parseJobReq({required String content}) {
    final lines = content.split('\n');
    if (lines.isEmpty) {
      return Left(const ParsingFailure(message: 'Job req content is empty'));
    }

    String bodyContent;
    Map<String, dynamic> fields = {};

    if (content.trim().startsWith('---')) {
      // YAML frontmatter format
      final endIndex = content.indexOf('\n---', 3);
      if (endIndex == -1) {
        return Left(
          ValidationFailure(
            message: 'Invalid YAML frontmatter: missing closing ---',
          ),
        );
      }
      final yamlContent = content.substring(3, endIndex);
      try {
        final yamlMap = loadYaml(yamlContent) as Map?;
        if (yamlMap != null) {
          fields = Map<String, dynamic>.from(yamlMap);
        }
      } catch (e) {
        return Left(ValidationFailure(message: 'Invalid YAML syntax: $e'));
      }
      bodyContent = content.substring(endIndex + 4).trim();
    } else if (lines[0].startsWith('- ') || lines[0].startsWith('* ')) {
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

    return Right(
      JobReq(
        id: (fields['job_req_id'] ?? fields['job req id'] ?? fields['id'] ?? '')
            .toString(),
        title:
            (fields['job_title'] ??
                    fields['job title'] ??
                    fields['title'] ??
                    '')
                .toString(),
        content: bodyContent,
        salary: fields['salary']?.toString(),
        location: fields['location']?.toString(),
        concern: fields['concern_name'] != null || fields['concern'] != null || fields['Concern'] != null
            ? Concern(
                name: (fields['concern_name'] ?? fields['concern'] ?? fields['Concern']).toString(),
                location: fields['location']?.toString(),
              )
            : null,
        state: (fields['state'] ?? 'raw').toString(),
        createdDate: fields['created_date'] != null
            ? DateTime.tryParse(fields['created_date'].toString())
            : fields['created date'] != null
            ? DateTime.tryParse(fields['created date'].toString())
            : fields['posted'] != null
            ? DateTime.tryParse(fields['posted'].toString())
            : null,
        whereFound:
            (fields['where_found'] ??
                    fields['where found'] ??
                    fields['company'] ??
                    '')
                .toString(),
      ),
    );
  }
}
