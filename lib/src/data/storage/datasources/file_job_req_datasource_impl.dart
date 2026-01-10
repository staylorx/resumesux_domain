import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:resumesux_domain/resumesux_domain.dart';

/// Implementation of FileJobReqDatasource.
class FileJobReqDatasourceImpl implements FileJobReqDatasource {
  @override
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

      final parseResult = _parseJobReq(content: content);
      return parseResult;
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to read job req: $e'));
    }
  }

  Either<Failure, JobReq> _parseJobReq({required String content}) {
    final lines = content.split('\n');
    if (lines.isEmpty) {
      return Left(const ParsingFailure(message: 'Job req content is empty'));
    }

    String bodyContent = content;
    Map<String, dynamic> fields = {};

    // Parse front matter
    int bodyStart = 0;
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      if (line.startsWith('##') || line.startsWith('# ')) {
        bodyStart = i;
        break;
      }
      final colonIndex = line.indexOf(': ');
      if (colonIndex != -1) {
        final key = line.substring(0, colonIndex).trim();
        final value = line.substring(colonIndex + 2).trim();
        fields[key] = value;
      } else {
        bodyStart = i;
        break;
      }
    }
    bodyContent = lines.sublist(bodyStart).join('\n').trim();

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
        concern:
            fields['concern_name'] != null ||
                fields['concern'] != null ||
                fields['Concern'] != null ||
                fields['company'] != null ||
                fields['client'] != null
            ? Concern(
                name:
                    (fields['concern_name'] ??
                            fields['concern'] ??
                            fields['Concern'] ??
                            fields['company']?.split(' ').first ??
                            fields['client'])
                        ?.toString() ??
                    '',
                location: fields['location']?.toString(),
              )
            : null,

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
