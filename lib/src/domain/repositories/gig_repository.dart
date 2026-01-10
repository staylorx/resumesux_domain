import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Repository for gig-related operations.
abstract class GigRepository {
  /// Retrieves all gigs.
  Future<Either<Failure, List<Gig>>> getAllGigs();

  /// Saves the last AI response to the specified file path.
  Future<Either<Failure, Unit>> saveAiResponse({required String filePath});
}
