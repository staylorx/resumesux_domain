import 'dart:convert';
import 'dart:io';
import 'package:fpdart/fpdart.dart';

import 'package:resumesux_domain/resumesux_domain.dart';

import '../../data.dart';

/// Implementation of the AssetRepository.
class AssetRepositoryImpl with Loggable implements AssetRepository {
  final String digestPath;
  final AiService aiService;
  final ApplicationDatasource applicationDatasource;
  final List<Map<String, dynamic>> _allAiResponses = [];

  AssetRepositoryImpl({
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

  Future<Either<Failure, Map<String, dynamic>>> _extractAssetData({
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
        id: 'asset_${path.hashCode}',
        content: jsonEncode(extractedData),
        contentType: 'application/json',
        aiResponseJson: '',
        documentType: 'ai_response',
        jobReqId: null,
      );
      final saveResult = await applicationDatasource.saveAiResponseDocument(
        dto,
      );
      if (saveResult.isLeft()) {
        logger?.warn(
          'Failed to save AI response for asset $path: ${saveResult.getLeft().toNullable()?.message}',
        );
        // Continue anyway
      }

      return Right(extractedData);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to extract asset data: $e'));
    }
  }

  String _buildExtractionPrompt({
    required String content,
    required String path,
  }) {
    return '''
Please analyze the following asset content and extract the following information in JSON format:

- tags: An array of relevant tags or skills extracted from the content (e.g., ["Dart", "Flutter", "React"])

File path: $path
The file path may contain information about the asset type. Use this to infer additional context if the content is ambiguous.

Return only valid JSON like:
{
  "tags": ["skill1", "skill2", "skill3"]
}

Do your best to extract meaningful tags from the content. If no specific tags can be extracted, use the asset type from the filename.

Asset content:
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
      return null;
    }
  }

  @override
  /// Retrieves all assets from the digest path.
  Future<Either<Failure, List<Asset>>> getAllAssets() async {
    try {
      final assetsDir = Directory('$digestPath/assets');
      if (!assetsDir.existsSync()) {
        return Right([]);
      }

      // TODO: is the same as the collection in Applicatant of Asset?
      final assets = <Asset>[];

      // Read files in assets directory
      final files = assetsDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.md'));

      for (final file in files) {
        final content = await file.readAsString();
        final extractResult = await _extractAssetData(
          content: content,
          path: file.path,
        );
        final data = extractResult.getOrElse((_) => {});
        if (extractResult.isLeft()) {
          logger?.warn(
            'Failed to extract asset data from ${file.path}: ${extractResult.getLeft().toNullable()?.message}',
          );
          // Fallback to basic extraction
          final type = _getAssetType(path: file.path);
          final asset = Asset(
            tags: [Tag(name: type)],
            content: content,
          );
          assets.add(asset);

          // Persist the asset to datastore
          final dto = AssetDto(
            id: 'asset_${asset.content.hashCode}',
            tagNames: asset.tags.map((tag) => tag.name).toList(),
            content: asset.content,
          );
          final saveResult = await applicationDatasource.saveAsset(dto);
          if (saveResult.isLeft()) {
            logger?.warn(
              'Failed to persist asset from ${file.path}: ${saveResult.getLeft().toNullable()?.message}',
            );
            // Continue anyway
          }
          continue;
        }
        if (data.isNotEmpty) {
          logger?.debug('Extracted asset data: $data');
        }

        final tags =
            (data['tags'] as List<dynamic>?)
                ?.map((tag) => Tag(name: tag as String))
                .toList() ??
            [Tag(name: _getAssetType(path: file.path))];

        final asset = Asset(tags: tags, content: content);
        assets.add(asset);

        // Persist the asset to datastore
        final dto = AssetDto(
          id: 'asset_${asset.content.hashCode}',
          tagNames: asset.tags.map((tag) => tag.name).toList(),
          content: asset.content,
        );
        final saveResult = await applicationDatasource.saveAsset(dto);
        if (saveResult.isLeft()) {
          logger?.warn(
            'Failed to persist asset from ${file.path}: ${saveResult.getLeft().toNullable()?.message}',
          );
          // Continue anyway
        }
      }

      return Right(assets);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to read assets: $e'));
    }
  }

  String _getAssetType({required String path}) {
    final parts = path.split(Platform.pathSeparator);
    final assetsIndex = parts.indexWhere((part) => part == 'assets');
    if (assetsIndex != -1 && assetsIndex + 1 < parts.length) {
      final nextPart = parts[assetsIndex + 1];
      if (nextPart.contains('.')) {
        // It's a file, get the name without extension
        return nextPart.split('.').first;
      } else {
        // It's a subdirectory
        return nextPart;
      }
    }
    return 'unknown';
  }

  @override
  Future<Either<Failure, Unit>> saveAiResponse({
    required String aiResponseJson,
    required String jobReqId,
  }) async {
    final dto = DocumentDto(
      id: 'asset_ai_$jobReqId',
      content: aiResponseJson,
      contentType: 'application/json',
      aiResponseJson: '',
      documentType: 'asset_response',
      jobReqId: jobReqId,
    );
    return applicationDatasource.saveAiResponseDocument(dto);
  }
}
