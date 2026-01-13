import 'dart:convert';
import 'package:fpdart/fpdart.dart';

import 'package:resumesux_domain/resumesux_domain.dart';

import '../../data.dart';

/// Implementation of the ResumeRepository.
class ResumeRepositoryImpl extends DocumentRepositoryImpl
    implements ResumeRepository {
  final ApplicationDatasource applicationDatasource;
  Map<String, dynamic>? _lastAiResponse;

  ResumeRepositoryImpl({
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
  Future<Either<Failure, Unit>> saveResume({
    required Resume resume,
    required String outputDir,
    required String jobTitle,
    required String jobReqId,
  }) async {
    final filePath = fileRepository.getResumeFilePath(
      appDir: outputDir,
      jobTitle: jobTitle,
    );
    final fileResult = await saveToFile(
      filePath: filePath,
      content: resume.content,
      documentType: 'Resume',
    );
    if (fileResult.isRight()) {
      // Save to DB
      final dto = DocumentDto(
        id: 'resume_$jobReqId',
        content: resume.content,
        contentType: resume.contentType,
        aiResponseJson: getLastAiResponseJson() ?? '',
        documentType: 'resume',
        jobReqId: jobReqId,
      );
      final dbResult = await applicationDatasource.saveDocument(dto);
      if (dbResult.isLeft()) {
        logger?.warning(
          'Failed to save resume to DB: ${dbResult.getLeft().toNullable()?.message}',
        );
      }
    }
    return fileResult;
  }

  @override
  Future<Either<Failure, Unit>> saveAiResponse({
    required String aiResponseJson,
    String? content,
    required String jobReqId,
  }) async {
    final dto = DocumentDto(
      id: 'resume_ai_$jobReqId', // Unique ID based on job req
      content: aiResponseJson,
      contentType: 'text/markdown',
      aiResponseJson: '',
      documentType: 'ai_response',
      jobReqId: jobReqId,
    );
    return applicationDatasource.saveDocument(dto);
  }
}
