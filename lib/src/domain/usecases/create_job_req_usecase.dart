import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for creating a new job requirement.
class CreateJobReqUsecase {
  final Logger logger = LoggerFactory.create('CreateJobReqUsecase');
  final JobReqRepository jobReqRepository;
  final AiService aiService;
  final FileRepository fileRepository;

  /// Creates a new instance of [CreateJobReqUsecase].
  CreateJobReqUsecase({
    required this.jobReqRepository,
    required this.aiService,
    required this.fileRepository,
  });

  /// Creates a new job requirement.
  ///
  /// Parameters:
  /// - [path]: Optional path to a job requirement file to extract data from.
  /// - [title]: The job title (required if path is not provided).
  /// - [content]: The job description content (required if path is not provided).
  /// - [salary]: Optional salary information.
  /// - [location]: Optional job location.
  /// - [concern]: Optional company concern.
  /// - [whereFound]: Optional source where the job was found.
  ///
  /// Returns: [Either<Failure, JobReq>] the created job requirement or a failure.
  Future<Either<Failure, JobReq>> call({
    String? path,
    String? title,
    String? content,
    String? salary,
    String? location,
    Concern? concern,
    String? whereFound,
  }) async {
    String finalTitle = title ?? '';
    String finalContent = content ?? '';
    String? finalSalary = salary;
    String? finalLocation = location;
    Concern? finalConcern = concern;
    String? finalWhereFound = whereFound;

    if (path != null) {
      logger.info(
        '[CreateJobReqUsecase] Extracting job req data from path: $path',
      );
      final extractResult = await _extractJobReqData(path: path);
      if (extractResult.isLeft()) {
        return extractResult.map((_) => throw '');
      }
      final data = extractResult.getOrElse((_) => {});
      finalTitle = data['title'] as String? ?? 'Unknown';
      finalContent = data['content'] as String? ?? '';
      finalSalary = data['salary'] as String?;
      finalLocation = data['location'] as String?;
      finalConcern = data['concern'] != null
          ? Concern(name: data['concern'] as String)
          : null;
      finalWhereFound = data['whereFound'] as String?;
    } else {
      if (finalTitle.isEmpty || finalContent.isEmpty) {
        return Left(
          ValidationFailure(
            message: 'title and content are required when path is not provided',
          ),
        );
      }
    }

    logger.info(
      '[CreateJobReqUsecase] Creating job req with title $finalTitle',
    );

    final createdDate = DateTime.now();

    final jobReq = JobReq(
      title: finalTitle,
      content: finalContent,
      salary: finalSalary,
      location: finalLocation,
      concern: finalConcern,
      createdDate: createdDate,
      whereFound: finalWhereFound,
    );

    try {
      return await jobReqRepository.createJobReq(jobReq: jobReq);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to create job req: $e'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> _extractJobReqData({
    required String path,
  }) async {
    final contentResult = fileRepository.readFile(path: path);
    if (contentResult.isLeft()) {
      return Left(contentResult.getLeft().toNullable()!);
    }
    final content = contentResult.getOrElse((_) => '');
    final prompt = _buildExtractionPrompt(content: content, path: path);

    final aiResult = await aiService.generateContent(prompt: prompt);
    if (aiResult.isLeft()) {
      return Left(aiResult.getLeft().toNullable()!);
    }

    final aiResponse = aiResult.getOrElse((_) => '');

    final extractedData = _parseAiResponse(aiResponse);
    if (extractedData == null) {
      return Left(
        ParsingFailure(message: 'Failed to parse AI response as JSON'),
      );
    }

    return Right(extractedData);
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
