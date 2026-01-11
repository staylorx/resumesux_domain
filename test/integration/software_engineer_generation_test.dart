import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'package:resumesux_domain/resumesux_domain.dart';
import '../test_utils.dart';

void main() {
  late DigestRepository digestRepository;
  late JobReqRepository jobReqRepository;

  late ResumeRepository resumeRepository;
  late CoverLetterRepository coverLetterRepository;
  late AiServiceImpl aiService;
  late GenerateResumeUsecase generateResumeUsecase;
  late GenerateCoverLetterUsecase generateCoverLetterUsecase;
  late GenerateFeedbackUsecase generateFeedbackUsecase;
  late CreateJobReqUsecase createJobReqUsecase;
  late GenerateApplicationUsecase generateApplicationUsecase;
  late FileRepository fileRepository;
  late SaveResumeUsecase saveResumeUsecase;
  late SaveFeedbackUsecase saveFeedbackUsecase;
  late SaveCoverLetterUsecase saveCoverLetterUsecase;
  late String suiteDir;
  late Logger logger;

  setUpAll(() async {
    // Set up logging
    Logger.root.level = Level.INFO;
    Logger.root.onRecord.listen((record) {
      // ignore: avoid_print
      print(
        '${record.level.name}: ${record.loggerName}: ${record.time}: ${record.message}',
      );
    });

    suiteDir = TestDirFactory.instance.createUniqueTestSuiteDir();

    logger = Logger('ResumeSoftwareEngineerGenerationTest');
    fileRepository = TestFileRepository();

    // Clear the database before the test group
    final datasource = JobReqSembastDatasource(
      dbPath: TestDirFactory.instance.setUpAllDbPath,
    );
    final result = await datasource.clearDatabase();
    result.fold(
      (failure) => logger.severe('Failure: ${failure.message}'),
      (_) => {},
    );
    expect(
      result.isRight(),
      true,
      reason: 'Failed to clear database before test group',
    );
  });

  setUp(() {
    aiService = AiServiceImpl(
      httpClient: http.Client(),
      provider: TestAiHelper.defaultProvider,
    );

    digestRepository = DigestRepositoryImpl(
      digestPath: 'test/data/digest/software_engineer',
      aiService: aiService,
    );
    jobReqRepository = JobReqRepositoryImpl(
      jobReqDatasource: JobReqSembastDatasource(
        dbPath: TestDirFactory.instance.setUpDbPath,
      ),
      aiService: aiService,
    );

    resumeRepository = ResumeRepositoryImpl(fileRepository: fileRepository);
    coverLetterRepository = CoverLetterRepositoryImpl(
      fileRepository: fileRepository,
    );

    generateResumeUsecase = GenerateResumeUsecase(
      digestRepository: digestRepository,
      aiService: aiService,
    );

    generateCoverLetterUsecase = GenerateCoverLetterUsecase(
      digestRepository: digestRepository,
      aiService: aiService,
    );

    generateFeedbackUsecase = GenerateFeedbackUsecase(aiService: aiService);

    createJobReqUsecase = CreateJobReqUsecase(
      jobReqRepository: jobReqRepository,
      aiService: aiService,
      fileRepository: fileRepository,
    );
    saveResumeUsecase = SaveResumeUsecase(fileRepository: fileRepository);
    saveCoverLetterUsecase = SaveCoverLetterUsecase(
      fileRepository: fileRepository,
    );
    saveFeedbackUsecase = SaveFeedbackUsecase(fileRepository: fileRepository);

    generateApplicationUsecase = GenerateApplicationUsecase(
      jobReqRepository: jobReqRepository,
      saveCoverLetterUsecase: saveCoverLetterUsecase,
      generateResumeUsecase: generateResumeUsecase,
      generateCoverLetterUsecase: generateCoverLetterUsecase,
      generateFeedbackUsecase: generateFeedbackUsecase,
      createJobReqUsecase: createJobReqUsecase,
      fileRepository: fileRepository,
      digestRepository: digestRepository,
      saveResumeUsecase: saveResumeUsecase,
      saveFeedbackUsecase: saveFeedbackUsecase,
    );

    logger = Logger('ResumeGenerationTest');
  });

  test('generate resume for software engineer job', () async {
    // Arrange
    final jobReqResult = await jobReqRepository.getJobReq(
      path: 'test/data/jobreqs/TechInnovate/Software Engineer/job_req.md',
    );
    expect(jobReqResult.isRight(), true);
    final jobReq = jobReqResult.getOrElse(
      (_) => throw Exception('Failed to load job req'),
    );

    final applicant = Applicant(
      name: 'John Doe',
      preferredName: 'John',
      email: 'john.doe@example.com',
      address: Address(
        street1: '123 Main St',
        city: 'Anytown',
        state: 'CA',
        zip: '12345',
      ),
      phone: '(555) 123-4567',
      linkedin: 'https://linkedin.com/in/johndoe',
      github: 'https://github.com/johndoe',
      portfolio: 'https://johndoe.dev',
    );

    // Act
    final result = await generateResumeUsecase.call(
      jobReq: jobReq,
      applicant: applicant,
      prompt: 'Generate a professional resume.',
    );

    // Assert
    expect(result.isRight(), true);
    final resume = result.getOrElse(
      (_) => throw Exception('Failed to generate resume'),
    );
    expect(resume.content, isNotEmpty);
    logger.info(
      'Resume generated successfully, content length: ${resume.content.length}',
    );

    final saveResult = await resumeRepository.saveResume(
      resume: resume,
      outputDir: suiteDir,
      jobTitle: 'software_engineer',
    );
    expect(saveResult.isRight(), true);
    logger.info('Resume saved to output folder');
  });

  test('generate cover letter for data scientist job', () async {
    // Arrange
    final jobReqResult = await jobReqRepository.getJobReq(
      path:
          'test/data/jobreqs/TelecomPlus/Customer Churn Prediction Model Development/data_scientist.md',
    );
    expect(jobReqResult.isRight(), true);
    final jobReq = jobReqResult.getOrElse(
      (_) => throw Exception('Failed to load job req'),
    );

    final applicant = Applicant(
      name: 'John Doe',
      preferredName: 'John',
      email: 'john.doe@example.com',
      address: Address(
        street1: '123 Main St',
        city: 'Anytown',
        state: 'CA',
        zip: '12345',
      ),
      phone: '(555) 123-4567',
      linkedin: 'https://linkedin.com/in/johndoe',
      github: 'https://github.com/johndoe',
      portfolio: 'https://johndoe.dev',
    );

    // Act
    final result = await generateCoverLetterUsecase.call(
      jobReq: jobReq,
      applicant: applicant,
      prompt: 'Generate a professional cover letter.',
    );

    // Assert
    expect(result.isRight(), true);
    final coverLetter = result.getOrElse(
      (_) => throw Exception('Failed to generate cover letter'),
    );
    expect(coverLetter.content, isNotEmpty);
    logger.info(
      'Cover letter generated successfully, content length: ${coverLetter.content.length}',
    );

    // Save cover letter to output folder
    final outputDir = suiteDir;

    // Create application directory for consistency
    final appDirResult = fileRepository.createApplicationDirectory(
      baseOutputDir: outputDir,
      jobReq: jobReq,
    );
    expect(appDirResult.isRight(), true);
    final appDir = appDirResult.getOrElse((_) => '');

    final saveResult = await coverLetterRepository.saveCoverLetter(
      coverLetter: coverLetter,
      outputDir: appDir,
      jobTitle: 'data_scientist',
    );
    expect(saveResult.isRight(), true);
    logger.info('Cover letter saved to output folder');
  });

  test(
    'generate application for TechInnovate Software Engineer job with correct output path',
    () async {
      // Arrange
      final outputDir = suiteDir;

      final applicant = Applicant(
        name: 'John Doe',
        preferredName: 'John',
        email: 'john.doe@example.com',
        address: Address(
          street1: '123 Main St',
          city: 'Anytown',
          state: 'CA',
          zip: '12345',
        ),
        phone: '(555) 123-4567',
        linkedin: 'https://linkedin.com/in/johndoe',
        github: 'https://github.com/johndoe',
        portfolio: 'https://johndoe.dev',
      );

      // Act
      final result = await generateApplicationUsecase.call(
        jobReqPath:
            'test/data/jobreqs/TechInnovate/Software Engineer/job_req.md',
        applicant: applicant,
        prompt: 'Generate a professional application.',
        outputDir: outputDir,
        includeCover: false,
        includeFeedback: false,
        progress: (message) => logger.info(message),
      );

      // Assert
      expect(result.isRight(), true);

      // Check that output directory structure is correct
      final techInnovateDirectory = Directory('$suiteDir/techinnovate_inc');
      expect(techInnovateDirectory.existsSync(), true);

      final subDirs = techInnovateDirectory.listSync().whereType<Directory>();
      expect(subDirs.length, greaterThan(0));

      // Find the most recent app dir (should contain senior_software_engineer)
      final appDir = subDirs.firstWhere(
        (dir) => dir.path.contains('senior_software_engineer'),
        orElse: () =>
            throw Exception('No app dir found for senior_software_engineer'),
      );
      // Check files exist
      final files = appDir.listSync().whereType<File>();
      final resumeFiles = files.where((f) => f.path.contains('resume_'));
      expect(resumeFiles.length, 1);
      expect(resumeFiles.first.existsSync(), true);
    },
  );
}
