import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';

import '../../core/failure.dart';
import '../../core/logger.dart';
import '../entities/job_req.dart';
import '../entities/resume.dart';
import '../entities/cover_letter.dart';
import '../entities/feedback.dart';
import '../entities/applicant.dart';
import '../../data/ai_gen/services/ai_service.dart';

// Parameters to control feedback generation:
// - tone: Controls the tone of feedback (0.0 = brutal feedback, 1.0 = enthusiastic feedback)
// - length: Controls the length of feedback (0.0 = brief, 1.0 = detailed)

/// Use case for generating feedback on an application.
class GenerateFeedbackUsecase {
  final Logger logger = LoggerFactory.create('GenerateFeedbackUsecase');
  final AiService aiService;

  /// Creates a new instance of [GenerateFeedbackUsecase].
  GenerateFeedbackUsecase({required this.aiService});

  /// Generates feedback for the given job requirement, resume, cover letter, and applicant.
  ///
  /// Parameters:
  /// - [jobReq]: The job requirement.
  /// - [resume]: The generated resume.
  /// - [coverLetter]: The generated cover letter.
  /// - [prompt]: The prompt for AI generation.
  /// - [applicant]: The applicant information.
  /// - [tone]: Controls the tone of feedback (0.0 = brutal feedback, 1.0 = enthusiastic feedback). Default is 0.5.
  /// - [length]: Controls the length of feedback (0.0 = brief, 1.0 = detailed). Default is 0.5.
  ///
  /// Returns: [Either<Failure, Feedback>] the generated feedback or a failure.
  Future<Either<Failure, Feedback>> call({
    required JobReq jobReq,
    required Resume resume,
    required CoverLetter coverLetter,
    required String prompt,
    required Applicant applicant,
    double tone = 0.5,
    double length = 0.5,
  }) async {
    logger.info('[GenerateFeedbackUsecase] Generating feedback');

    final fullPrompt = _buildFeedbackPrompt(
      jobReq: jobReq.content,
      resume: resume.content,
      coverLetter: coverLetter.content,
      customPrompt: prompt,
      tone: tone,
      length: length,
    );

    final result = await aiService.generateContent(prompt: fullPrompt);
    return result.map((content) => Feedback(content: content));
  }

  String _getToneInstruction(double tone) {
    if (tone <= 0.2) {
      return 'Be brutally honest and critical, pointing out all flaws harshly without sugarcoating.';
    } else if (tone <= 0.4) {
      return 'Be direct and critical, focusing on weaknesses while offering minimal constructive input.';
    } else if (tone <= 0.6) {
      return 'Provide constructive feedback with a balanced approach, addressing both strengths and areas for improvement.';
    } else if (tone <= 0.8) {
      return 'Be encouraging with constructive suggestions, emphasizing potential and positive aspects.';
    } else {
      return 'Be enthusiastic and kind, focusing on strengths, highlighting achievements, and providing supportive guidance.';
    }
  }

  String _getLengthInstruction(double length) {
    if (length <= 0.2) {
      return 'Provide a very brief summary, focusing only on the most critical points.';
    } else if (length <= 0.4) {
      return 'Provide a short overview, covering key aspects concisely.';
    } else if (length <= 0.6) {
      return 'Provide balanced feedback with moderate detail on important elements.';
    } else if (length <= 0.8) {
      return 'Provide detailed feedback, elaborating on multiple aspects.';
    } else {
      return 'Provide a comprehensive and detailed analysis, covering all relevant areas thoroughly.';
    }
  }

  String _buildFeedbackPrompt({
    required String jobReq,
    required String resume,
    required String coverLetter,
    required String customPrompt,
    required double tone,
    required double length,
  }) {
    final toneInstruction = _getToneInstruction(tone);
    final lengthInstruction = _getLengthInstruction(length);

    return '''
$customPrompt

Job Requirements:
$jobReq

Generated Resume:
$resume

Generated Cover Letter:
$coverLetter

$toneInstruction $lengthInstruction Include suggestions for improvement on how well this application matches the job requirements.
''';
  }
}
