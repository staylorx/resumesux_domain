import 'dart:convert';
import 'dart:io';
import 'package:fpdart/fpdart.dart';

import 'package:resumesux_domain/resumesux_domain.dart';

import '../../data.dart';

/// Implementation of the GigRepository.
class GigRepositoryImpl with Loggable implements GigRepository {
  final String digestPath;
  final AiService aiService;
  final ApplicationDatasource applicationDatasource;
  final List<Map<String, dynamic>> _allAiResponses = [];

  GigRepositoryImpl({
    Logger? logger,
    required this.digestPath,
    required this.aiService,
    required this.applicationDatasource,
  }) {
    this.logger = logger;
  }

  @override
  String? getLastAiResponsesJson() {
    return _allAiResponses.isNotEmpty ? jsonEncode(_allAiResponses) : null;
  }

  Future<Either<Failure, Map<String, dynamic>>> _extractGigData({
    required String content,
    required String path,
  }) async {
    try {
      final prompt = _buildExtractionPrompt(content: content, path: path);

      final aiResult = await aiService.generateContent(prompt: prompt);
      if (aiResult.isLeft()) {
        return Left(aiResult.getLeft().toNullable()!);
      }

      final aiResponse = aiResult.getOrElse((_) => '');

      final extractedData = _parseAiResponse(response: aiResponse);
      if (extractedData == null) {
        return Left(
          ParsingFailure(message: 'Failed to parse AI response as JSON'),
        );
      }

      _allAiResponses.add(extractedData);

      // Save AI response to datastore
      final dto = DocumentDto(
        id: 'gig_${path.hashCode}',
        content: jsonEncode(extractedData),
        contentType: 'application/json',
        aiResponseJson: '',
        documentType: 'gig_response',
        jobReqId: null,
      );
      final saveResult = await applicationDatasource.saveAiResponseDocument(
        dto,
      );
      if (saveResult.isLeft()) {
        logger?.warn(
          'Failed to save AI response for gig $path: ${saveResult.getLeft().toNullable()?.message}',
        );
        // Continue anyway
      }

      return Right(extractedData);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to extract gig data: $e'));
    }
  }

  String _buildExtractionPrompt({
    required String content,
    required String path,
  }) {
    return '''
Please analyze the following gig content and extract the following information in JSON format:

- title: The job title or position
- concern: The company or organization name (if mentioned, otherwise null)
- location: The job location (if mentioned, otherwise null)
- dates: The employment dates (if mentioned, otherwise null)
- achievements: An array of achievements or responsibilities (if mentioned, otherwise null)

File path: $path
The file path may contain information about the concern (company), job title, location, etc. Use this to infer missing details if the content is ambiguous.

Return only valid JSON like:
{
  "title": "Software Engineer",
  "concern": "StartupXYZ",
  "location": "Remote",
  "dates": "June 2018 - December 2020",
  "achievements": ["Developed RESTful APIs using Node.js and Express", "Built responsive web applications with React", "Integrated third-party services and payment gateways", "Collaborated with design team for pixel-perfect implementations"]
}

Do your best, but if information is absolutely not present, use null. Make no assumptions beyond the content provided and the file path.

Gig content:
$content
''';
  }

  Map<String, dynamic>? _parseAiResponse({required String response}) {
    try {
      // Try to extract JSON from response
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      if (jsonStart == -1 || jsonEnd == 0) return null;
      final jsonString = response.substring(jsonStart, jsonEnd);
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      logger?.warn('Failed to parse AI response: $e\nResponse was: $response');
      return null;
    }
  }

  @override
  /// Retrieves all gigs from the digest path.
  Future<Either<Failure, List<Gig>>> getAllGigs() async {
    try {
      final gigsDir = Directory('$digestPath/gigs');
      if (!gigsDir.existsSync()) {
        return Right([]);
      }

      // TODO: is this the same as the applicant collection of Gig?
      final gigs = <Gig>[];
      final files = gigsDir.listSync().whereType<File>().where(
        (file) => file.path.endsWith('.md'),
      );

      for (final file in files) {
        final content = await file.readAsString();
        final extractResult = await _extractGigData(
          content: content,
          path: file.path,
        );
        final data = extractResult.getOrElse((_) => {});
        if (extractResult.isLeft()) {
          logger?.warn(
            'Failed to extract gig data from ${file.path}: ${extractResult.getLeft().toNullable()?.message}',
          );
          continue;
        }
        if (data.isNotEmpty) {
          logger?.debug('Extracted gig data: $data');
        }

        final gig = Gig(
          title: data['title'] as String? ?? 'Unknown',
          concern: data['concern'] as String?,
          location: data['location'] as String?,
          dates: data['dates'] as String?,
          achievements: (data['achievements'] as List<dynamic>?)
              ?.cast<String>(),
        );
        gigs.add(gig);

        // Persist the gig to datastore
        final dto = GigDto(
          id: 'gig_${gig.title.hashCode}_${gig.concern?.hashCode ?? ''}',
          concern: gig.concern,
          location: gig.location,
          title: gig.title,
          dates: gig.dates,
          achievements: gig.achievements,
        );
        final saveResult = await applicationDatasource.saveGig(dto);
        if (saveResult.isLeft()) {
          logger?.warn(
            'Failed to persist gig ${gig.title}: ${saveResult.getLeft().toNullable()?.message}',
          );
          // Continue anyway
        }
      }

      return Right(gigs);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to read gigs: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveAiResponse({
    required String aiResponseJson,
    required String jobReqId,
  }) async {
    final dto = DocumentDto(
      id: 'gig_ai_$jobReqId',
      content: aiResponseJson,
      contentType: 'application/json',
      aiResponseJson: '',
      documentType: 'gig_response',
      jobReqId: jobReqId,
    );
    return applicationDatasource.saveAiResponseDocument(dto);
  }
}
