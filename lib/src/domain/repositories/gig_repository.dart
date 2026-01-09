import 'package:fpdart/fpdart.dart';
import 'package:resume_suckage_domain/resume_suckage_domain.dart';

/// Repository for gig-related operations.
abstract class GigRepository {
  /// Retrieves all gigs.
  Future<Either<Failure, List<Gig>>> getAllGigs();
}
