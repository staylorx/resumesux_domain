import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for generating a complete job application and saving it to a folder.
/// This combines generation and persistence into a single operation.
class GenerateAndSaveApplicationUsecase {
  final Logger logger = LoggerFactory.create(
    name: 'GenerateAndSaveApplicationUsecase',
  );
  final GenerateApplicationUsecase generateApplicationUsecase;
  final CreateApplicationDirectoryUsecase createApplicationDirectoryUsecase;
  final SaveResumeUsecase saveResumeUsecase;
  final SaveCoverLetterUsecase saveCoverLetterUsecase;
  final SaveFeedbackUsecase saveFeedbackUsecase;
  final FileRepository fileRepository;

  /// Creates a new instance of [GenerateAndSaveApplicationUsecase].
  GenerateAndSaveApplicationUsecase({
    required this.generateApplicationUsecase,
    required this.createApplicationDirectoryUsecase,
    required this.saveResumeUsecase,
    required this.saveCoverLetterUsecase,
    required this.saveFeedbackUsecase,
    required this.fileRepository,
  });

  /// Generates an application and saves it to the specified output directory.
  ///
  /// This method orchestrates the generation of a resume, optional cover letter,
  /// and optional feedback, then creates an application directory and saves all
  /// components to files within that directory.
  ///
  /// Parameters:
  /// - [jobReq]: The job requirement entity.
  /// - [applicant]: The applicant information.
  /// - [prompt]: The prompt for AI generation.
  /// - [includeCover]: Whether to include a cover letter.
  /// - [includeFeedback]: Whether to include feedback.
  /// - [tone]: Tone parameter for feedback generation (0.0 = brutal, 1.0 = enthusiastic).
  /// - [length]: Length parameter for feedback generation (0.0 = brief, 1.0 = detailed).
  /// - [baseOutputDir]: The base output directory where the application folder will be created.
  /// - [progress]: Callback function to report progress messages.
  ///
  /// Returns: [Either<Failure, Unit>] the result containing the application and output directory path, or a failure.
  Future<Either<Failure, Unit>> call({
    required JobReq jobReq,
    required Applicant applicant,
    required String prompt,
    required bool includeCover,
    required bool includeFeedback,
    double tone = 0.5,
    double length = 0.5,
    required String baseOutputDir,
    required void Function(String) progress,
  }) async {
    progress(
      'Starting application generation and saving for job: ${jobReq.title}',
    );
    logger.info(
      'Starting application generation and saving for job: ${jobReq.title}',
    );

    // Generate the application
    progress('Generating application components');
    logger.info('Generating application components');
    final applicationResult = await generateApplicationUsecase(
      jobReq: jobReq,
      applicant: applicant,
      prompt: prompt,
      includeCover: includeCover,
      includeFeedback: includeFeedback,
      tone: tone,
      length: length,
      progress: progress,
    );
    if (applicationResult.isLeft()) {
      return Left(applicationResult.getLeft().toNullable()!);
    }
    final application = applicationResult.getOrElse(
      (_) => Application(
        applicant: applicant,
        jobReq: jobReq,
        resume: Resume(content: ''),
        coverLetter: CoverLetter(content: ''),
        feedback: Feedback(content: ''),
      ),
    );
    progress('Application components generated successfully');
    logger.info('Application components generated successfully');

    // Create the application directory
    progress('Creating application directory');
    logger.info('Creating application directory');
    final dirResult = await createApplicationDirectoryUsecase(
      baseOutputDir: baseOutputDir,
      jobReq: jobReq,
    );
    if (dirResult.isLeft()) {
      return Left(dirResult.getLeft().toNullable()!);
    }
    final outputDir = dirResult.getOrElse((_) => '');
    progress('Application directory created: $outputDir');
    logger.info('Application directory created: $outputDir');

    // Save resume
    progress('Saving resume');
    logger.info('Saving resume');
    final resumePath = fileRepository.getResumeFilePath(
      appDir: outputDir,
      jobTitle: jobReq.title,
    );
    final saveResumeResult = await saveResumeUsecase(
      resume: application.resume,
      filePath: resumePath,
    );
    if (saveResumeResult.isLeft()) {
      return Left(saveResumeResult.getLeft().toNullable()!);
    }
    progress('Resume saved successfully');
    logger.info('Resume saved successfully');

    // Save cover letter if included
    if (includeCover && application.coverLetter.content.isNotEmpty) {
      progress('Saving cover letter');
      logger.info('Saving cover letter');
      final coverPath = fileRepository.getCoverLetterFilePath(
        appDir: outputDir,
        jobTitle: jobReq.title,
      );
      final saveCoverResult = await saveCoverLetterUsecase(
        coverLetter: application.coverLetter,
        filePath: coverPath,
      );
      if (saveCoverResult.isLeft()) {
        return Left(saveCoverResult.getLeft().toNullable()!);
      }
      progress('Cover letter saved successfully');
      logger.info('Cover letter saved successfully');
    }

    // Save feedback if included
    if (includeFeedback && application.feedback.content.isNotEmpty) {
      progress('Saving feedback');
      logger.info('Saving feedback');
      final feedbackPath = fileRepository.getFeedbackFilePath(
        appDir: outputDir,
      );
      final saveFeedbackResult = await saveFeedbackUsecase(
        feedback: application.feedback,
        filePath: feedbackPath,
      );
      if (saveFeedbackResult.isLeft()) {
        return Left(saveFeedbackResult.getLeft().toNullable()!);
      }
      progress('Feedback saved successfully');
      logger.info('Feedback saved successfully');
    }

    progress('Application generated and saved successfully');
    logger.info('Application generated and saved successfully');
    return Right(unit);
  }
}
