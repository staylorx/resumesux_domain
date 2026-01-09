import 'dart:convert';
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
      // Get the job req from file
      final jobReqResult = await jobReqRepository.getJobReq(path: path);
      if (jobReqResult.isLeft()) {
        return Left(jobReqResult.getLeft().toNullable()!);
      }
      final jobReq = jobReqResult.getOrElse(
        (_) => throw Exception('Unexpected error'),
      );

      // Build prompt
      final prompt = _buildExtractionPrompt(content: jobReq.content);

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
      final preprocessedJobReq = jobReq.copyWith(
        title: extractedData['title'] as String? ?? jobReq.title,
        salary: extractedData['salary'] as String?,
        location: extractedData['location'] as String?,
        concern: extractedData['concern'] != null
            ? Concern(
                name: extractedData['concern'] as String,
                location: extractedData['location'] as String?,
              )
            : jobReq.concern,
        state: 'pre-processed',
      );

      // Save to Sembast
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

  String _buildExtractionPrompt({required String content}) {
    return '''
Please analyze the following job requirement content and extract the following information in JSON format:

- title: The job title
- salary: The salary information (if mentioned, otherwise null)
- location: The job location (if mentioned, otherwise null)
- concern: The company or organization name (if mentioned, otherwise null)

Return only valid JSON like:
{
  "title": "Software Engineer",
  "salary": "\$100,000 - \$120,000",
  "location": "San Francisco, CA",
  "concern": "Tech Company Inc."
}

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
