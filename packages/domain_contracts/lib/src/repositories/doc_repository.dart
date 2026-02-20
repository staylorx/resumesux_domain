import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Repository for doc-related operations.
abstract class DocRepository {
  /// Retrieves the last AI response as JSON string.
  String? getLastAiResponseJson();

  /// Sets the last AI response.
  void setLastAiResponse(Map<String, dynamic> response);

  /// Saves the AI responses JSON for docs to the database.
  Future<Either<Failure, Unit>> saveAiResponse({
    required String aiResponseJson,
    required String jobReqId,
    String? content,
  });
}
