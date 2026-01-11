import 'package:fpdart/fpdart.dart';

import 'package:logging/logging.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for generating a complete job application including resume, cover letter, and feedback.
class GenerateApplicationUsecase {
  final Logger logger = LoggerFactory.create('GenerateApplicationUsecase');
  final JobReqRepository jobReqRepository;
  final GenerateResumeUsecase generateResumeUsecase;
  final GenerateCoverLetterUsecase generateCoverLetterUsecase;
  final GenerateFeedbackUsecase generateFeedbackUsecase;
  final SaveResumeUsecase saveResumeUsecase;
  final SaveCoverLetterUsecase saveCoverLetterUsecase;
  final SaveFeedbackUsecase saveFeedbackUsecase;
  final CreateJobReqUsecase createJobReqUsecase;
  final FileRepository fileRepository;
  final DigestRepository digestRepository;

  /// Creates a new instance of [GenerateApplicationUsecase].
  GenerateApplicationUsecase({
    required this.jobReqRepository,
    required this.generateResumeUsecase,
    required this.generateCoverLetterUsecase,
    required this.generateFeedbackUsecase,
    required this.saveResumeUsecase,
    required this.saveCoverLetterUsecase,
    required this.saveFeedbackUsecase,
    required this.createJobReqUsecase,
    required this.fileRepository,
    required this.digestRepository,
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

    // Create application directory using the repository
    final appDirResult = fileRepository.createApplicationDirectory(
      baseOutputDir: outputDir,
      jobReq: jobReq,
    );
    if (appDirResult.isLeft()) {
      return appDirResult.map((_) => unit);
    }
    final appDirPath = appDirResult.getOrElse((_) => '');

    // Save AI response to application directory
    final aiResponseFilePath = fileRepository.getAiResponseFilePath(
      appDir: appDirPath,
      type: 'jobreq',
    );
    final saveAiResult = await jobReqRepository.saveAiResponse(
      filePath: aiResponseFilePath,
    );
    if (saveAiResult.isLeft()) {
      final failure = saveAiResult.getLeft().toNullable()!;
      logger.warning('Failed to save AI response: ${failure.message}');
      // Continue anyway, as it's not critical
    }

    // Get digest to trigger AI calls for gigs and assets
    progress('Retrieving applicant data');
    logger.info('Retrieving applicant data');
    final digestResult = await digestRepository.getAllDigests();
    if (digestResult.isLeft()) {
      return Left(digestResult.getLeft().toNullable()!);
    }

    // Save AI responses for gigs and assets
    final gigAiResponseFilePath = fileRepository.getAiResponseFilePath(
      appDir: appDirPath,
      type: 'gig',
    );
    final saveGigAiResult = await digestRepository.saveGigAiResponse(
      filePath: gigAiResponseFilePath,
    );
    if (saveGigAiResult.isLeft()) {
      final failure = saveGigAiResult.getLeft().toNullable()!;
      logger.warning('Failed to save gig AI response: ${failure.message}');
      // Continue anyway
    }

    final assetAiResponseFilePath = fileRepository.getAiResponseFilePath(
      appDir: appDirPath,
      type: 'asset',
    );
    final saveAssetAiResult = await digestRepository.saveAssetAiResponse(
      filePath: assetAiResponseFilePath,
    );
    if (saveAssetAiResult.isLeft()) {
      final failure = saveAssetAiResult.getLeft().toNullable()!;
      logger.warning('Failed to save asset AI response: ${failure.message}');
      // Continue anyway
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

    // Save resume
    final resumeFilePath = fileRepository.getResumeFilePath(
      appDir: appDirPath,
      jobTitle: jobReq.title,
    );
    final saveResumeResult = await saveResumeUsecase(
      resume: resume,
      filePath: resumeFilePath,
    );
    if (saveResumeResult.isLeft()) {
      final failure = saveResumeResult.getLeft().toNullable()!;
      progress('Failed to save resume: ${failure.message}');
      logger.severe('Failed to save resume: ${failure.message}');
      return saveResumeResult.map((_) => unit);
    }

    // Save cover letter if provided
    if (coverLetter != null && coverLetter.content.isNotEmpty) {
      final coverFilePath = fileRepository.getCoverLetterFilePath(
        appDir: appDirPath,
        jobTitle: jobReq.title,
      );
      final saveCoverResult = await saveCoverLetterUsecase(
        coverLetter: coverLetter,
        filePath: coverFilePath,
      );
      if (saveCoverResult.isLeft()) {
        final failure = saveCoverResult.getLeft().toNullable()!;
        progress('Failed to save cover letter: ${failure.message}');
        logger.severe('Failed to save cover letter: ${failure.message}');
        return saveCoverResult.map((_) => unit);
      }
    }

    // Save feedback if provided
    if (feedback.content.isNotEmpty) {
      final feedbackFilePath = fileRepository.getFeedbackFilePath(
        appDir: appDirPath,
      );
      final saveFeedbackResult = await saveFeedbackUsecase(
        feedback: feedback,
        filePath: feedbackFilePath,
      );
      if (saveFeedbackResult.isLeft()) {
        final failure = saveFeedbackResult.getLeft().toNullable()!;
        progress('Failed to save feedback: ${failure.message}');
        logger.severe('Failed to save feedback: ${failure.message}');
        return saveFeedbackResult.map((_) => unit);
      }
    }

    progress('Application saved successfully');
    logger.info('Application saved successfully');
    return Right(unit);
  }
}
