import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:resumesux_domain/resumesux_domain.dart';
import '../test_utils.dart';

void main() {
  late DigestRepository digestRepository;
  late JobReqRepository jobReqRepository;
  late ResumeRepository resumeRepository;
  late CoverLetterRepository coverLetterRepository;
  late ApplicationRepository applicationRepository;
  late AiServiceImpl aiService;
  late GenerateResumeUsecase generateResumeUsecase;
  late GenerateCoverLetterUsecase generateCoverLetterUsecase;
  late GenerateFeedbackUsecase generateFeedbackUsecase;
  late GetDigestUsecase getDigestUsecase;
  late GenerateApplicationUsecase generateApplicationUsecase;
  late FileRepository fileRepository;
  late ApplicationDatasource applicationDatasource;
  late String suiteDir;
  late Logger logger;
  late TestSuiteReadmeManager readmeManager;

  setUpAll(() async {
    suiteDir = TestDirFactory.instance.createUniqueTestSuiteDir();

    // Set up logging
    Logger.root.level = Level.ALL;
    final logFile = File(path.join(suiteDir, 'log.txt'));
    Logger.root.onRecord.listen((record) {
      logFile.writeAsStringSync(
        '${record.level.name}: ${record.loggerName}: ${record.time}: ${record.message}\n',
        mode: FileMode.append,
      );
    });

    readmeManager = TestSuiteReadmeManager(
      suiteDir: suiteDir,
      suiteName: 'Software Engineer Generation Test',
    );
    readmeManager.initialize();

    logger = Logger('ResumeSoftwareEngineerGenerationTest');
    fileRepository = TestFileRepository();

    aiService = AiServiceImpl(
      httpClient: http.Client(),
      provider: TestAiHelper.defaultProvider,
    );
    final dbService = SembastDatabaseService(
      dbPath: suiteDir,
      dbName: 'applications.db',
    );
    applicationDatasource = ApplicationDatasource(dbService: dbService);
  });

  setUp(() {
    digestRepository = DigestRepositoryImpl(
      digestPath: 'test/data/digest/software_engineer',
      aiService: aiService,
      applicationDatasource: applicationDatasource,
    );
    jobReqRepository = JobReqRepositoryImpl(
      aiService: aiService,
      applicationDatasource: applicationDatasource,
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
      digestRepository: digestRepository,
      aiService: aiService,
    );

    generateCoverLetterUsecase = GenerateCoverLetterUsecase(
      digestRepository: digestRepository,
      aiService: aiService,
    );

    generateFeedbackUsecase = GenerateFeedbackUsecase(aiService: aiService);

    getDigestUsecase = GetDigestUsecase(
      gigRepository: digestRepository.gigRepository,
      assetRepository: digestRepository.assetRepository,
    );

    generateApplicationUsecase = GenerateApplicationUsecase(
      generateResumeUsecase: generateResumeUsecase,
      generateCoverLetterUsecase: generateCoverLetterUsecase,
      generateFeedbackUsecase: generateFeedbackUsecase,
      getDigestUsecase: getDigestUsecase,
    );

    logger = Logger('ResumeGenerationTest');
  });

  group('Software Engineer Tests', () {
    readmeManager.startGroup('Software Engineer Tests');

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

  tearDownAll(() {
    readmeManager.finalize();
  });
}
