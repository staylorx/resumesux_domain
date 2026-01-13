import 'package:http/http.dart' as http;
import 'package:id_logging/id_logging.dart';
import 'package:test/test.dart';
import 'package:resumesux_domain/src/domain/domain.dart';
import 'package:resumesux_domain/src/data/data.dart';
import 'package:resumesux_db_sembast/resumesux_db_sembast.dart';
import '../test_utils.dart';

void main() {
  late GigRepository gigRepository;
  late AssetRepository assetRepository;
  late JobReqRepository jobReqRepository;
  late ResumeRepository resumeRepository;
  late CoverLetterRepository coverLetterRepository;
  late ApplicationRepository applicationRepository;
  late ApplicantRepository applicantRepository;
  late AiServiceImpl aiService;
  late GenerateResumeUsecase generateResumeUsecase;
  late GenerateCoverLetterUsecase generateCoverLetterUsecase;
  late GenerateFeedbackUsecase generateFeedbackUsecase;
  late SaveAiResponsesUsecase saveAiResponsesUsecase;
  late GenerateApplicationUsecase generateApplicationUsecase;
  late FileRepository fileRepository;
  late ApplicationDatasource applicationDatasource;
  late String suiteDir;
  late Logger logger;
  late TestSuiteReadmeManager readmeManager;
  late SembastDatabaseService dbService;

  suiteDir = TestDirFactory.instance.createUniqueTestSuiteDir();

  logger = ConsoleLoggerImpl(name: 'SoftwareEngineerGenerationTest');

  readmeManager = TestSuiteReadmeManager(
    suiteDir: suiteDir,
    suiteName: 'Software Engineer Generation Test',
  );
  readmeManager.initialize();

  logger = FileLoggerImpl(
    filePath: '$suiteDir/test_log.txt',
    name: 'SoftwareEngineerGenerationTests',
  );

  setUpAll(() async {
    readmeManager.startGroup('Software Engineer Tests');

    aiService = AiServiceImpl(
      logger: logger,
      httpClient: http.Client(),
      provider: TestAiHelper.defaultProvider,
    );

    // Initialize the database before the test group
    dbService = SembastDatabaseService(
      dbPath: suiteDir,
      dbName: 'applications.db',
    );
    await dbService.initialize();

    applicationDatasource = ApplicationDatasource(dbService: dbService);
  });

  tearDownAll(() async {
    readmeManager.finalize();
    await dbService.close();
    aiService.httpClient.close();
  });

  setUp(() {
    fileRepository = TestFileRepository();

    gigRepository = GigRepositoryImpl(
      digestPath: 'test/data/digest/software_engineer',
      aiService: aiService,
      applicationDatasource: applicationDatasource,
    );
    assetRepository = AssetRepositoryImpl(
      digestPath: 'test/data/digest/software_engineer',
      aiService: aiService,
      applicationDatasource: applicationDatasource,
    );
    jobReqRepository = JobReqRepositoryImpl(
      aiService: aiService,
      applicationDatasource: applicationDatasource,
    );

    final configRepository = ConfigRepositoryImpl(
      configDatasource: ConfigDatasource(),
    );
    applicantRepository = ApplicantRepositoryImpl(
      configRepository: configRepository,
      applicationDatasource: applicationDatasource,
      aiService: aiService,
    );

    resumeRepository = ResumeRepositoryImpl(
      fileRepository: fileRepository,
      applicationDatasource: applicationDatasource,
    );
    coverLetterRepository = CoverLetterRepositoryImpl(
      fileRepository: fileRepository,
      applicationDatasource: applicationDatasource,
    );
    applicationRepository = ApplicationRepositoryImpl(
      applicationDatasource: applicationDatasource,
      fileRepository: fileRepository,
      resumeRepository: resumeRepository,
      coverLetterRepository: coverLetterRepository,
      feedbackRepository: FeedbackRepositoryImpl(
        fileRepository: fileRepository,
        applicationDatasource: applicationDatasource,
      ),
    );

    generateResumeUsecase = GenerateResumeUsecase(
      aiService: aiService,
      logger: logger,
      resumeRepository: resumeRepository,
    );

    generateCoverLetterUsecase = GenerateCoverLetterUsecase(
      aiService: aiService,
      logger: logger,
    );

    generateFeedbackUsecase = GenerateFeedbackUsecase(
      aiService: aiService,
      logger: logger,
      jobReqRepository: jobReqRepository,
      gigRepository: gigRepository,
      assetRepository: assetRepository,
    );

    saveAiResponsesUsecase = SaveAiResponsesUsecase(
      jobReqRepository: jobReqRepository,
      gigRepository: gigRepository,
      assetRepository: assetRepository,
      logger: logger,
    );

    generateApplicationUsecase = GenerateApplicationUsecase(
      generateResumeUsecase: generateResumeUsecase,
      generateCoverLetterUsecase: generateCoverLetterUsecase,
      generateFeedbackUsecase: generateFeedbackUsecase,
      saveAiResponsesUsecase: saveAiResponsesUsecase,
      logger: logger,
    );
  });

  group('Software Engineer Tests', () {
    test('generate resume for software engineer job', () async {
      final testName = 'generate resume for software engineer job';
      readmeManager.startTest(testName);

      try {
        // Arrange
        final jobReqResult = await jobReqRepository.getJobReq(
          path: 'test/data/jobreqs/TechInnovate/Software Engineer/job_req.md',
        );
        expect(jobReqResult.isRight(), true);
        final jobReq = jobReqResult.getOrElse(
          (_) => throw Exception('Failed to load job req'),
        );

        final baseApplicant = Applicant(
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

        final importResult = await applicantRepository.importDigest(
          applicant: baseApplicant,
          digestPath: 'test/data/digest/software_engineer',
        );
        final applicant = importResult.getOrElse(
          (failure) =>
              throw Exception('Failed to import digest: ${failure.message}'),
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
          jobReqId: jobReq.hashCode.toString(),
        );
        expect(saveResult.isRight(), true);
        logger.info('Resume saved to output folder');

        readmeManager.endTest(testName, true);
      } catch (e) {
        readmeManager.endTest(testName, false, error: e.toString());
        rethrow;
      }
    });

    test(
      'generate cover letter for data scientist job',
      () async {
        final testName = 'generate cover letter for data scientist job';
        readmeManager.startTest(testName);

        try {
          // Arrange
          final jobReqResult = await jobReqRepository.getJobReq(
            path:
                'test/data/jobreqs/TelecomPlus/Customer Churn Prediction Model Development/data_scientist.md',
          );
          expect(jobReqResult.isRight(), true);
          final jobReq = jobReqResult.getOrElse(
            (_) => throw Exception('Failed to load job req'),
          );

          final baseApplicant = Applicant(
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

          final importResult = await applicantRepository.importDigest(
            applicant: baseApplicant,
            digestPath: 'test/data/digest/software_engineer',
          );
          final applicant = importResult.getOrElse(
            (failure) =>
                throw Exception('Failed to import digest: ${failure.message}'),
          );

          // Generate a resume first
          final resumeResult = await generateResumeUsecase.call(
            jobReq: jobReq,
            applicant: applicant,
            prompt: 'Generate a professional resume.',
          );
          expect(resumeResult.isRight(), true);
          final resume = resumeResult.getOrElse(
            (_) => throw Exception('Failed to generate resume'),
          );

          // Act
          final result = await generateCoverLetterUsecase.call(
            jobReq: jobReq,
            resume: resume,
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
            jobReqId: jobReq.hashCode.toString(),
          );
          expect(saveResult.isRight(), true);
          logger.info('Cover letter saved to output folder');

          readmeManager.endTest(testName, true);
        } catch (e) {
          readmeManager.endTest(testName, false, error: e.toString());
          rethrow;
        }
      },
      timeout: Timeout(Duration(seconds: 120)),
    );

    test(
      'generate application for TechInnovate Software Engineer job with correct output path',
      () async {
        final testName =
            'generate application for TechInnovate Software Engineer job with correct output path';
        readmeManager.startTest(testName);

        try {
          final baseApplicant = Applicant(
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

          final importResult = await applicantRepository.importDigest(
            applicant: baseApplicant,
            digestPath: 'test/data/digest/software_engineer',
          );
          final applicant = importResult.getOrElse(
            (failure) =>
                throw Exception('Failed to import digest: ${failure.message}'),
          );

          final jobReqResult = await jobReqRepository.getJobReq(
            path: 'test/data/jobreqs/TechInnovate/Software Engineer/job_req.md',
          );
          expect(jobReqResult.isRight(), true);
          final jobReq = jobReqResult.getOrElse(
            (_) => throw Exception('Failed to load job req'),
          );

          // Act
          final result = await generateApplicationUsecase.call(
            jobReq: jobReq,
            applicant: applicant,
            prompt: 'Generate a professional application.',
            includeCover: false,
            includeFeedback: false,
            progress: (message) => logger.info(message),
          );

          // Assert
          expect(result.isRight(), true);
          final application = result.getOrElse(
            (_) => throw Exception('Failed to generate application'),
          );

          // Save the application artifacts
          final saveResult = await applicationRepository
              .saveApplicationArtifacts(
                application: application,
                outputDir: suiteDir,
              );
          expect(saveResult.isRight(), true);

          readmeManager.endTest(testName, true);
        } catch (e) {
          readmeManager.endTest(testName, false, error: e.toString());
          rethrow;
        }
      },
    );
  });
}
