import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for generating or improving frontmatter for a job requirement file.
class GenerateJobReqFrontmatterUsecase {
  final Logger logger = LoggerFactory.create(
    'GenerateJobReqFrontmatterUsecase',
  );
  final JobReqRepository jobReqRepository;
  final AiService aiService;

  /// Creates a new instance of [GenerateJobReqFrontmatterUsecase].
  GenerateJobReqFrontmatterUsecase({
    required this.jobReqRepository,
    required this.aiService,
  });

  /// Generates or improves the frontmatter for the job requirement file at the given path.
  ///
  /// Parameters:
  /// - [path]: The file path to the job requirement file.
  ///
  /// Returns: [Either<Failure, JobReq>] the updated job requirement or a failure.
  Future<Either<Failure, JobReq>> call({required String path}) async {
    logger.info(
      '[GenerateJobReqFrontmatterUsecase] Generating frontmatter for $path',
    );

    try {
      final file = File(path);
      if (!file.existsSync()) {
        return Left(NotFoundFailure(message: 'Job req file not found: $path'));
      }

      final content = await file.readAsString();

      // Try to get existing JobReq, but if no frontmatter, proceed with empty
      final existingJobReqResult = await jobReqRepository.getJobReq(path: path);
      final existingJobReq = existingJobReqResult.fold(
        (_) => null,
        (jobReq) => jobReq,
      );

      final prompt = _buildFrontmatterPrompt(
        content: content,
        existingId: existingJobReq?.id,
        existingTitle: existingJobReq?.title,
        existingWhereFound: existingJobReq?.whereFound,
        existingConcernName: existingJobReq?.concern?.name,
        filename: path.split(Platform.pathSeparator).last,
      );

      final aiResult = await aiService.generateContent(prompt: prompt);
      if (aiResult.isLeft()) {
        return Left(aiResult.getLeft().toNullable()!);
      }

      final frontmatterYaml = aiResult.getOrElse((_) => '');
      final updatedJobReq = _parseFrontmatterAndCreateJobReq(
        yamlContent: frontmatterYaml,
        bodyContent: content,
        existingJobReq: existingJobReq,
      );

      // Note: Not saving to file anymore, just returning the parsed JobReq
      return Right(updatedJobReq);
    } catch (e) {
      return Left(
        ServiceFailure(message: 'Failed to generate frontmatter: $e'),
      );
    }
  }

  String _buildFrontmatterPrompt({
    required String content,
    String? existingId,
    String? existingTitle,
    String? existingWhereFound,
    String? existingConcernName,
    required String filename,
  }) {
    return '''
Please analyze the following job requirement content and generate or improve the frontmatter fields in YAML format.

Existing frontmatter (if any):
- job_req_id: ${existingId ?? 'Not present'}
- job_title: ${existingTitle ?? 'Not present'}
- where_found: ${existingWhereFound ?? 'Not present'}
- concern_name: ${existingConcernName ?? 'Not present'}

Filename: $filename

Job requirement content:
$content

Instructions:
- job_req_id: Generate a unique ID based on the filename if not present or improve if exists. Format: something like "JOB-XXXX" where XXXX is derived from filename.
- job_title: Extract or improve the job title from the content.
- created_date: Use current date in ISO 8601 format (YYYY-MM-DD) if not present.
- where_found: Extract the source if mentioned in content, otherwise 'Unknown'.
- concern_name: Extract the company, organization, or team name if mentioned in content, otherwise 'Unknown'.

Return only the YAML frontmatter without the --- delimiters, like:
job_req_id: "JOB-EXAMPLE"
job_title: "Example Job Title"
created_date: "2023-12-12"
where_found: "Unknown"
concern_name: "The Best Company In The World, Inc."

Do your best, but if information is absolutely not present, use 'Unknown'. Make no assumptions beyond the content provided.
''';
  }

  JobReq _parseFrontmatterAndCreateJobReq({
    required String yamlContent,
    required String bodyContent,
    JobReq? existingJobReq,
  }) {
    // Parse the YAML (assuming it's valid)
    final lines = yamlContent.split('\n');
    final Map<String, dynamic> fields = {};
    for (final line in lines) {
      if (line.contains(':')) {
        final parts = line.split(':');
        final key = parts[0].trim();
        final value = parts
            .sublist(1)
            .join(':')
            .trim()
            .replaceAll('"', '')
            .replaceAll("'", '');
        if (key == 'processed') {
          fields[key] = value.toLowerCase() == 'true';
        } else if (key == 'created_date') {
          fields[key] = DateTime.tryParse(value);
        } else {
          fields[key] = value;
        }
      }
    }

    return JobReq(
      id: (fields['job_req_id'] as String?) ?? existingJobReq?.id ?? '',
      title: (fields['job_title'] as String?) ?? existingJobReq?.title ?? '',
      content: bodyContent,
      concern: fields['concern_name'] != null
          ? Concern(name: fields['concern_name'] as String)
          : existingJobReq?.concern,
      state: 'raw',
      createdDate:
          (fields['created_date'] as DateTime?) ??
          existingJobReq?.createdDate ??
          DateTime.now(),
      whereFound:
          (fields['where_found'] as String?) ??
          existingJobReq?.whereFound ??
          'Unknown',
    );
  }
}
