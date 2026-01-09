import 'dart:convert';
import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for preprocessing a job requirement by extracting key information using AI.
class PreprocessJobReqUsecase {
  final Logger logger = LoggerFactory.create('PreprocessJobReqUsecase');
  final JobReqRepository jobReqRepository;
  final AiService aiService;

  /// Creates a new instance of [PreprocessJobReqUsecase].
  PreprocessJobReqUsecase({
    required this.jobReqRepository,
    required this.aiService,
  });

  /// Preprocesses the job requirement at the given path by extracting title, salary, location, and concern using AI.
  ///
  /// Parameters:
  /// - [path]: The file path to the job requirement file.
  ///
  /// Returns: [Either<Failure, JobReq>] the preprocessed job requirement or a failure.
  Future<Either<Failure, JobReq>> call({required String path}) async {
    logger.info('[PreprocessJobReqUsecase] Preprocessing job req at $path');

    try {
      final file = File(path);
      if (!file.existsSync()) {
        return Left(NotFoundFailure(message: 'Job req file not found: $path'));
      }

      final content = await file.readAsString();

      // Try to get existing JobReq, but if parsing fails, proceed with empty
      final existingJobReqResult = await jobReqRepository.getJobReq(path: path);
      final existingJobReq = existingJobReqResult.fold(
        (_) => null,
        (jobReq) => jobReq,
      );

      // Build prompt
      final prompt = _buildExtractionPrompt(content: content, path: path);

      // Call AI
      final aiResult = await aiService.generateContent(prompt: prompt);
      if (aiResult.isLeft()) {
        return Left(aiResult.getLeft().toNullable()!);
      }

      final aiResponse = aiResult.getOrElse((_) => '');
      logger.fine('[PreprocessJobReqUsecase] AI response: $aiResponse');

      // Parse JSON
      final extractedData = _parseAiResponse(aiResponse);
      if (extractedData == null) {
        return Left(
          ParsingFailure(message: 'Failed to parse AI response as JSON'),
        );
      }

      // Create updated JobReq
      final preprocessedJobReq = JobReq(
        id: existingJobReq?.id ?? '',
        title: extractedData['title'] as String? ?? existingJobReq?.title ?? '',
        content: content,
        salary: extractedData['salary'] as String?,
        location: extractedData['location'] as String?,
        concern: extractedData['concern'] != null
            ? Concern(
                name: extractedData['concern'] as String,
                location: extractedData['location'] as String?,
              )
            : existingJobReq?.concern,
        state: 'pre-processed',
        createdDate: existingJobReq?.createdDate ?? DateTime.now(),
        whereFound: existingJobReq?.whereFound ?? 'Unknown',
      );

      // Save to repository
      final saveResult = await jobReqRepository.updateJobReq(
        jobReq: preprocessedJobReq,
      );
      if (saveResult.isLeft()) {
        return Left(saveResult.getLeft().toNullable()!);
      }

      return Right(preprocessedJobReq);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to preprocess job req: $e'));
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
}
