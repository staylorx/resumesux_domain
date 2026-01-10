import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Abstract service for AI content generation.
abstract class AiService {
  /// Generates content using AI based on the provided prompt.
  Future<Either<Failure, String>> generateContent({required String prompt});
}
