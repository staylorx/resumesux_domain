import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/src/domain/domain.dart';

/// Use case for generating a complete job application including resume, cover letter, and feedback.
class GenerateApplicationUsecase {
  final Logger? logger;
  final GenerateResumeUsecase generateResumeUsecase;
  final GenerateCoverLetterUsecase generateCoverLetterUsecase;
  final GenerateFeedbackUsecase generateFeedbackUsecase;

  final SaveAiResponsesUsecase saveAiResponsesUsecase;

  /// Creates a new instance of [GenerateApplicationUsecase].
  GenerateApplicationUsecase({
    this.logger,
    required this.generateResumeUsecase,
    required this.generateCoverLetterUsecase,
    required this.generateFeedbackUsecase,
    required this.saveAiResponsesUsecase,
  });

  /// Generates an application for the given job requirement.
  ///
  /// This method orchestrates the generation of a resume, optional cover letter,
  /// and optional feedback based on the provided parameters.
  ///
  /// Parameters:
  /// - [jobReq]: The job requirement entity.
  /// - [applicant]: The applicant information.
  /// - [prompt]: The prompt for AI generation.
  /// - [includeCover]: Whether to include a cover letter.
  /// - [includeFeedback]: Whether to include feedback.
  /// - [tone]: Tone parameter for feedback generation (0.0 = brutal, 1.0 = enthusiastic).
  /// - [length]: Length parameter for feedback generation (0.0 = brief, 1.0 = detailed).
  /// - [progress]: Callback function to report progress messages.
  ///
  /// Returns: [Either<Failure, Application>] the generated application or a failure.
  Future<Either<Failure, Application>> call({
    required JobReq jobReq,
    required Applicant applicant,
    required String prompt,
    required bool includeCover,
    required bool includeFeedback,
    double tone = 0.5,
    double length = 0.5,
    required void Function(String) progress,
  }) async {
    progress('Starting application generation for job: ${jobReq.title}');
    logger?.info('Starting application generation for job: ${jobReq.title}');

    progress('Generating resume');
    logger?.info('Generating resume');
    // Generate resume
    final resumeResult = await generateResumeUsecase(
      jobReq: jobReq,
      applicant: applicant,
      prompt: prompt,
    );
    if (resumeResult.isLeft()) {
      return Left(resumeResult.getLeft().toNullable()!);
    }

    final resume = resumeResult.getOrElse((_) => Resume(content: ''));
    progress('Resume generated successfully');
    logger?.info('Resume generated successfully');

    // Generate cover letter if requested
    CoverLetter coverLetter;
    if (includeCover) {
      progress('Generating cover letter');
      logger?.info('Generating cover letter');
      final coverResult = await generateCoverLetterUsecase(
        jobReq: jobReq,
        resume: resume,
        applicant: applicant,
        prompt: prompt,
      );
      if (coverResult.isLeft()) {
        return Left(coverResult.getLeft().toNullable()!);
      }
      coverLetter = coverResult.getOrElse((_) => CoverLetter(content: ''));
      progress('Cover letter generated successfully');
    } else {
      coverLetter = CoverLetter(content: '');
    }

    // Generate feedback if requested
    Feedback feedback;
    if (includeFeedback) {
      progress('Generating feedback');
      logger?.info('Generating feedback');
      final feedbackResult = await generateFeedbackUsecase(
        jobReq: jobReq,
        resume: resume,
        coverLetter: coverLetter,
        prompt: prompt,
        applicant: applicant,
        tone: tone,
        length: length,
      );
      if (feedbackResult.isLeft()) {
        return Left(feedbackResult.getLeft().toNullable()!);
      }
      feedback = feedbackResult.getOrElse((_) => Feedback(content: ''));
      progress('Feedback generated successfully');
    } else {
      feedback = Feedback(content: '');
    }

    final application = Application(
      applicant: applicant,
      jobReq: jobReq,
      resume: resume,
      coverLetter: coverLetter,
      feedback: feedback,
    );

    // Save AI responses
    final saveResult = await saveAiResponsesUsecase.call(
      jobReqId: jobReq.hashCode.toString(),
    );
    if (saveResult.isLeft()) {
      final failure = saveResult.getLeft().toNullable()!;
      logger?.warn('Failed to save AI responses: ${failure.message}');
      // Continue anyway, as it's not critical
    }

    progress('Application generated successfully');
    logger?.info('Application generated successfully');
    return Right(application);
  }
}
