import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';
import 'package:resumesux_domain/src/domain/value_objects/handles/gig_handle.dart';

// Projection for CLI output
class GigWithHandle {
  final GigHandle handle;
  final Gig gig;
  GigWithHandle({required this.handle, required this.gig});
}

/// Repository for gig-related operations.
abstract class GigRepository {
  /// Retrieves all gigs.
  Future<Either<Failure, List<Gig>>> getAllGigs();

  Future<Either<Failure, List<GigWithHandle>>> getAll(); // For listing

  /// Retrieves the last AI responses as JSON string.
  String? getLastAiResponsesJson();

  /// Saves the AI responses JSON for gigs to the database.
  Future<Either<Failure, Unit>> saveAiResponse({
    required String aiResponseJson,
    required String jobReqId,
  });
}
