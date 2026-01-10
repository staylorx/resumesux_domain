import 'dart:convert';
import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Implementation of the JobReqRepository.
class JobReqRepositoryImpl implements JobReqRepository {
  final Logger logger = LoggerFactory.create('JobReqRepositoryImpl');
  final JobReqDatasource jobReqDatasource;
  final AiService aiService;
  String? _lastAiResponse;

  JobReqRepositoryImpl({
    required this.jobReqDatasource,
    required this.aiService,
  });
  @override
  Future<Either<Failure, JobReq>> createJobReq({required JobReq jobReq}) async {
    return await jobReqDatasource.createJobReq(jobReq: jobReq);
  }

  @override
  /// Updates an existing job requirement.
  Future<Either<Failure, Unit>> updateJobReq({required JobReq jobReq}) async {
    return await jobReqDatasource.updateJobReq(jobReq: jobReq);
  }

  @override
  /// Retrieves a job requirement from the given path.
  Future<Either<Failure, JobReq>> getJobReq({required String path}) async {
    final extractResult = await _extractJobReqData(path: path);
    final data = extractResult.getOrElse((_) => {});
    if (extractResult.isLeft()) {
      return Left(extractResult.getLeft().toNullable()!);
    }
    if (data.isNotEmpty) {
      logger.fine('Extracted job req data: $data');
    }

    final jobReq = JobReq(
      id: DateTime.now().toIso8601String(),
      title: data['title'] as String? ?? 'Unknown',
      content: data['content'] as String? ?? '',
      salary: data['salary'] as String?,
      location: data['location'] as String?,
      concern: data['concern'] != null
          ? Concern(name: data['concern'] as String)
          : null,
      createdDate: DateTime.now(),
      whereFound: data['whereFound'] as String?,
    );

    // Save to database for persistence
    await jobReqDatasource.updateJobReq(jobReq: jobReq);
    return Right(jobReq);
  }

  Future<Either<Failure, Map<String, dynamic>>> _extractJobReqData({
    required String path,
  }) async {
    try {
      final file = File(path);
      if (!file.existsSync()) {
        return Left(NotFoundFailure(message: 'Job req file not found: $path'));
      }
      final content = await file.readAsString();
      final prompt = _buildExtractionPrompt(content: content, path: path);

      final aiResult = await aiService.generateContent(prompt: prompt);
      if (aiResult.isLeft()) {
        return Left(aiResult.getLeft().toNullable()!);
      }

      final aiResponse = aiResult.getOrElse((_) => '');
      _lastAiResponse = aiResponse;

      final extractedData = _parseAiResponse(aiResponse);
      if (extractedData == null) {
        return Left(
          ParsingFailure(message: 'Failed to parse AI response as JSON'),
        );
      }

      return Right(extractedData);
    } catch (e) {
      return Left(
        ServiceFailure(message: 'Failed to extract job req data: $e'),
      );
    }
  }

  String _buildExtractionPrompt({
    required String content,
    required String path,
  }) {
    return '''
Please analyze the following job requirement content and extract the following information in JSON format:

- title: The job title
- salary: The salary information (if mentioned, otherwise null)
- location: The job location (if mentioned, otherwise null)
- concern: The company or organization name (if mentioned, otherwise null)

File path: $path
The file path may contain information about the concern (company), job title, location, etc. Use this to infer missing details if the content is ambiguous.

Return only valid JSON like:
{
  "title": "Software Engineer",
  "salary": "\$100,000 - \$120,000",
  "location": "San Francisco, CA",
  "concern": "Tech Company Inc."
}

Do your best, but if information is absolutely not present, use 'Unknown'. Make no assumptions beyond the content provided and the file path.

Job requirement content:
$content
''';
  }

  Map<String, dynamic>? _parseAiResponse(String response) {
    try {
      // Try to extract JSON from response
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      if (jsonStart == -1 || jsonEnd == 0) return null;
      final jsonString = response.substring(jsonStart, jsonEnd);
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Either<Failure, Unit>> saveAiResponse({
    required String filePath,
  }) async {
    try {
      if (_lastAiResponse == null) {
        return Left(ServiceFailure(message: 'No AI response to save'));
      }
      final file = File(filePath);
      await file.writeAsString(_lastAiResponse!);
      logger.info('Saved AI response to ${file.path}');
      return Right(unit);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to save AI response: $e'));
    }
  }
}
