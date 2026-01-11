import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Repository for gig-related operations.
abstract class GigRepository {
  /// Retrieves all gigs.
  Future<Either<Failure, List<Gig>>> getAllGigs();

  /// Retrieves the last AI responses as JSON string.
  String? getLastAiResponsesJson();

  /// Saves the AI responses JSON for gigs to the database.
  Future<Either<Failure, Unit>> saveAiResponse({
    required String aiResponseJson,
    required String jobReqId,
  });
}
