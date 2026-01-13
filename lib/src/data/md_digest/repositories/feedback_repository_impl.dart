import 'dart:convert';
import 'package:fpdart/fpdart.dart';

import 'package:resumesux_domain/resumesux_domain.dart';

import '../../data.dart';

/// Implementation of the FeedbackRepository.
class FeedbackRepositoryImpl extends DocumentRepositoryImpl
    implements FeedbackRepository {
  final ApplicationDatasource applicationDatasource;
  Map<String, dynamic>? _lastAiResponse;

  FeedbackRepositoryImpl({
    super.logger,
    required super.fileRepository,
    required this.applicationDatasource,
  });

  @override
  String? getLastAiResponseJson() {
    return _lastAiResponse != null ? jsonEncode(_lastAiResponse) : null;
  }

  @override
  void setLastAiResponse(Map<String, dynamic> response) {
    _lastAiResponse = response;
  }

  @override
  Future<Either<Failure, Unit>> saveFeedback({
    required Feedback feedback,
    required String outputDir,
    required String jobReqId,
  }) async {
    final filePath = fileRepository.getFeedbackFilePath(appDir: outputDir);
    final fileResult = await saveToFile(
      filePath: filePath,
      content: feedback.content,
      documentType: 'Feedback',
    );
    if (fileResult.isRight()) {
      // Save to DB
      final dto = DocumentDto(
        id: 'feedback_$jobReqId',
        content: feedback.content,
        contentType: feedback.contentType,
        aiResponseJson: getLastAiResponseJson() ?? '',
        documentType: 'feedback',
        jobReqId: jobReqId,
      );
      final dbResult = await applicationDatasource.saveDocument(dto);
      if (dbResult.isLeft()) {
        logger?.warn(
          'Failed to save feedback to DB: ${dbResult.getLeft().toNullable()?.message}',
        );
      }
    }
    return fileResult;
  }

  @override
  Future<Either<Failure, Unit>> saveAiResponse({
    required String aiResponseJson,
    required String content,
    required String jobReqId,
  }) async {
    final dto = DocumentDto(
      id: 'feedback_ai_$jobReqId',
      content: aiResponseJson,
      contentType: 'text/markdown',
      aiResponseJson: '',
      documentType: 'ai_response',
      jobReqId: jobReqId,
    );
    return applicationDatasource.saveDocument(dto);
  }
}
