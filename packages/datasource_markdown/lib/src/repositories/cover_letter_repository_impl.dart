import 'dart:convert';
import 'package:fpdart/fpdart.dart';

import 'package:resumesux_domain/resumesux_domain.dart';

import 'package:resumesux_domain/src/data/data.dart';

/// Implementation of the CoverLetterRepository.
class CoverLetterRepositoryImpl extends DocumentRepositoryImpl
    implements CoverLetterRepository {
  final ApplicationDatasource applicationDatasource;
  Map<String, dynamic>? _lastAiResponse;

  CoverLetterRepositoryImpl({
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
  Future<Either<Failure, Unit>> saveCoverLetter({
    required CoverLetter coverLetter,
    required String outputDir,
    required String jobTitle,
    required String jobReqId,
  }) async {
    final filePath = fileRepository.getCoverLetterFilePath(
      appDir: outputDir,
      jobTitle: jobTitle,
    );
    final fileResult = await saveToFile(
      filePath: filePath,
      content: coverLetter.content,
      documentType: 'CoverLetter',
    );
    if (fileResult.isRight()) {
      // Save to DB
      final dto = DocumentDto(
        id: 'cover_letter_$jobReqId',
        content: coverLetter.content,
        contentType: coverLetter.contentType,
        aiResponseJson: getLastAiResponseJson() ?? '',
        documentType: 'cover_letter',
        jobReqId: jobReqId,
      );
      final dbResult = await applicationDatasource.saveDocument(dto);
      if (dbResult.isLeft()) {
        logger?.warning(
          'Failed to save cover letter to DB: ${dbResult.getLeft().toNullable()?.message}',
        );
      }
    }
    return fileResult;
  }

  @override
  Future<Either<Failure, Unit>> saveAiResponse({
    required String aiResponseJson,
    required String jobReqId,
    String? content,
  }) async {
    final dto = DocumentDto(
      id: 'cover_letter_ai_$jobReqId',
      content: aiResponseJson,
      contentType: 'text/markdown',
      aiResponseJson: '',
      documentType: 'ai_response',
      jobReqId: jobReqId,
    );
    return applicationDatasource.saveDocument(dto);
  }
}
