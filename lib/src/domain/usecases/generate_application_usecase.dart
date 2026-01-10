import 'package:fpdart/fpdart.dart';

import 'package:logging/logging.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for generating a complete job application including resume, cover letter, and feedback.
class GenerateApplicationUsecase {
  final Logger logger = LoggerFactory.create('GenerateApplicationUsecase');
  final JobReqRepository jobReqRepository;
  final ApplicationRepository applicationRepository;
  final GenerateResumeUsecase generateResumeUsecase;
  final GenerateCoverLetterUsecase generateCoverLetterUsecase;
  final GenerateFeedbackUsecase generateFeedbackUsecase;
  final CreateJobReqUsecase createJobReqUsecase;
  final OutputDirectoryService outputDirectoryService;

  /// Creates a new instance of [GenerateApplicationUsecase].
  GenerateApplicationUsecase({
    required this.jobReqRepository,
    required this.applicationRepository,
    required this.generateResumeUsecase,
    required this.generateCoverLetterUsecase,
    required this.generateFeedbackUsecase,
    required this.createJobReqUsecase,
    required this.outputDirectoryService,
  });

  /// Generates an application for the given job requirement.
  ///
  /// This method orchestrates the generation of a resume, optional cover letter,
  /// and optional feedback based on the provided parameters. It saves the
  /// generated application to the specified output directory and marks the
  /// job requirement as processed.
  ///
  /// Parameters:
  /// - [jobReqPath]: Path to the job requirement file.
  /// - [applicant]: The applicant information.
  /// - [prompt]: The prompt for AI generation.
  /// - [outputDir]: Directory to save the application.
  /// - [includeCover]: Whether to include a cover letter.
  /// - [includeFeedback]: Whether to include feedback.
  /// - [tone]: Tone parameter for feedback generation (0.0 = brutal, 1.0 = enthusiastic).
  /// - [length]: Length parameter for feedback generation (0.0 = brief, 1.0 = detailed).
  /// - [progress]: Callback function to report progress messages.
  ///
  /// Returns: [Either<Failure, Unit>] indicating success or failure.
  Future<Either<Failure, Unit>> call({
    required String jobReqPath,
    required Applicant applicant,
    required String prompt,
    required String outputDir,
    required bool includeCover,
    required bool includeFeedback,
    double tone = 0.5,
    double length = 0.5,
    required void Function(String) progress,
  }) async {
    progress('Starting application generation for job: $jobReqPath');
    logger.info('Starting application generation for job: $jobReqPath');

    // Get job req
    var jobReqResult = await jobReqRepository.getJobReq(path: jobReqPath);
    if (jobReqResult.isLeft()) {
      final failure = jobReqResult.getLeft().toNullable()!;
      if (failure is ParsingFailure) {
        progress('Parsing failed, preprocessing job req for: $jobReqPath');
        logger.info('Parsing failed, preprocessing job req for $jobReqPath');
        final preprocessResult = await createJobReqUsecase(path: jobReqPath);
        if (preprocessResult.isLeft()) {
          return preprocessResult.map((_) => unit);
        }
        // Retry getJobReq
        jobReqResult = await jobReqRepository.getJobReq(path: jobReqPath);
        if (jobReqResult.isLeft()) return jobReqResult.map((_) => unit);
      } else {
        return jobReqResult.map((_) => unit);
      }
    }

    final jobReq = (jobReqResult as Right<Failure, JobReq>).value;

    // Create application directory using the service
    final appDirResult = outputDirectoryService.createApplicationDirectory(
      baseOutputDir: outputDir,
      jobReq: jobReq,
    );
    if (appDirResult.isLeft()) {
      return appDirResult.map((_) => unit);
    }
    final appDirPath = appDirResult.getOrElse((_) => '');

    // Save AI response to application directory
    final aiResponseFilePath = outputDirectoryService.getAiResponseFilePath(
      appDirPath,
      'jobreq',
    );
    final saveAiResult = await jobReqRepository.saveAiResponse(
      filePath: aiResponseFilePath,
    );
    if (saveAiResult.isLeft()) {
      final failure = saveAiResult.getLeft().toNullable()!;
      logger.warning('Failed to save AI response: ${failure.message}');
      // Continue anyway, as it's not critical
    }

    progress('Generating resume');
    logger.info('Generating resume');
    // Generate resume
    final resumeResult = await generateResumeUsecase(
      jobReq: jobReq,
      applicant: applicant,
      prompt: prompt,
    );
    if (resumeResult.isLeft()) return resumeResult.map((_) => unit);

    final resume = (resumeResult as Right<Failure, Resume>).value;
    progress('Resume generated successfully');
    logger.info('Resume generated successfully');

    // Generate cover letter if requested
    CoverLetter? coverLetter;
    if (includeCover) {
      progress('Generating cover letter');
      logger.info('Generating cover letter');
      final coverResult = await generateCoverLetterUsecase(
        jobReq: jobReq,
        applicant: applicant,
        prompt: prompt,
      );
      if (coverResult.isLeft()) return coverResult.map((_) => unit);
      coverLetter = (coverResult as Right<Failure, CoverLetter>).value;
      progress('Cover letter generated successfully');
    }

    // Generate feedback if requested
    Feedback feedback;
    if (includeFeedback) {
      progress('Generating feedback');
      logger.info('Generating feedback');
      final feedbackResult = await generateFeedbackUsecase(
        jobReq: jobReq,
        resume: resume,
        coverLetter: coverLetter ?? CoverLetter(content: ''),
        prompt: prompt,
        applicant: applicant,
        tone: tone,
        length: length,
      );
      if (feedbackResult.isLeft()) return feedbackResult.map((_) => unit);
      feedback = (feedbackResult as Right<Failure, Feedback>).value;
      progress('Feedback generated successfully');
    } else {
      feedback = Feedback(content: '');
    }

    // Save application
    progress('Saving application');
    logger.info('Saving application to output directory: $outputDir');
    final saveResult = await applicationRepository.saveApplication(
      jobReqId: jobReq.id,
      jobTitle: jobReq.title,
      resume: resume,
      coverLetter: coverLetter ?? CoverLetter(content: ''),
      feedback: feedback,
      appDirPath: appDirPath,
    );

    if (saveResult.isRight()) {
      progress('Application saved successfully');
      logger.info('Application saved successfully');
    } else {
      final failure = saveResult.getLeft().toNullable()!;
      progress('Failed to save application: ${failure.message}');
      logger.severe('Failed to save application: ${failure.message}');
    }

    return saveResult;
  }
}
