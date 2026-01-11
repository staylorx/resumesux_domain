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
  late String suiteDir;
  late Logger logger;
  late ApplicationDatasource applicationDatasource;
  late TestSuiteReadmeManager readmeManager;
  late SembastDatabaseService dbService;

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

    logger = Logger('ResumeHeavyEquipmentOperatorGenerationTest');

    readmeManager = TestSuiteReadmeManager(
      suiteDir: suiteDir,
      suiteName: 'Heavy Equipment Operator Generation Test',
    );
    readmeManager.initialize();
    readmeManager.startGroup('Heavy Equipment Operator Tests');

    aiService = AiServiceImpl(
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

    digestRepository = DigestRepositoryImpl(
      digestPath: 'test/data/digest/heavy_equipment_operator',
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
  });

  group('Heavy Equipment Operator Tests', () {
    /// purposefully wierd application of operator to data science job req
    test('generate resume for heavy equipment operator job', () async {
      final testName = 'generate resume for heavy equipment operator job';
      readmeManager.startTest(testName);

      try {
        // Arrange
        final jobReqResult = await jobReqRepository.getJobReq(
          path:
              'test/data/jobreqs/DataDriven Analytics/Senior Data Scientist/job_req.md',
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
        expect(resume.content, contains('excavator'));
        expect(resume.content, contains('bulldozer'));
        expect(resume.content, isNot(contains('Python')));
        expect(resume.content, isNot(contains('machine learning')));
        logger.info(
          'Resume generated successfully, content length: ${resume.content.length}',
        );

        final saveResult = await resumeRepository.saveResume(
          resume: resume,
          outputDir: suiteDir,
          jobTitle: 'heavy_equipment_operator',
        );
        expect(saveResult.isRight(), true);
        logger.info('Resume saved to output folder');

        readmeManager.endTest(testName, true);
      } catch (e) {
        readmeManager.endTest(testName, false, error: e.toString());
        rethrow;
      }
    });

    test('generate cover letter for heavy equipment operator job', () async {
      final testName = 'generate cover letter for heavy equipment operator job';
      readmeManager.startTest(testName);

      try {
        // Arrange
        final jobReqResult = await jobReqRepository.getJobReq(
          path:
              'test/data/jobreqs/DataDriven Analytics/Senior Data Scientist/job_req.md',
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
        expect(coverLetter.content, contains('excavator'));
        expect(coverLetter.content, contains('bulldozer'));
        expect(coverLetter.content, isNot(contains('Python')));
        expect(coverLetter.content, isNot(contains('machine learning')));
        logger.info(
          'Cover letter generated successfully, content length: ${coverLetter.content.length}',
        );

        final saveResult = await coverLetterRepository.saveCoverLetter(
          coverLetter: coverLetter,
          outputDir: suiteDir,
          jobTitle: 'heavy_equipment_operator',
        );
        expect(saveResult.isRight(), true);
        logger.info('Cover letter saved to output folder');

        readmeManager.endTest(testName, true);
      } catch (e) {
        readmeManager.endTest(testName, false, error: e.toString());
        rethrow;
      }
    });

    test(
      'generate application for DataDriven Analytics Senior Data Scientist job with heavy equipment operator data',
      () async {
        final testName =
            'generate application for DataDriven Analytics Senior Data Scientist job with heavy equipment operator data';
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
            path:
                'test/data/jobreqs/DataDriven Analytics/Senior Data Scientist/job_req.md',
          );
          final jobReq = jobReqResult.getOrElse(
            (_) => throw Exception('Failed to load job req'),
          );

          // Act
          logger.info('Starting generateApplicationUsecase.call');
          final stopwatch = Stopwatch()..start();
          final result = await generateApplicationUsecase.call(
            jobReq: jobReq,
            applicant: applicant,
            prompt: 'Generate a professional application.',
            includeCover: true,
            includeFeedback: true,
            progress: (message) => logger.info(message),
          );
          stopwatch.stop();
          logger.info(
            'generateApplicationUsecase.call completed in ${stopwatch.elapsedMilliseconds} ms',
          );

          // Assert
          expect(result.isRight(), true);
          final application = result.getOrElse(
            (_) => throw Exception('Failed to generate application'),
          );

          // Save the application artifacts
          logger.info('Starting saveApplicationArtifacts');
          final saveStopwatch = Stopwatch()..start();
          final saveResult = await applicationRepository
              .saveApplicationArtifacts(
                application: application,
                outputDir: suiteDir,
              );
          saveStopwatch.stop();
          logger.info(
            'saveApplicationArtifacts completed in ${saveStopwatch.elapsedMilliseconds} ms',
          );
          expect(saveResult.isRight(), true);

          // Check that output directory structure is correct
          logger.info('Starting directory structure checks');
          final dirCheckStopwatch = Stopwatch()..start();
          final dataDrivenDirectory = Directory(
            '$suiteDir/datadriven_analytics',
          );
          expect(dataDrivenDirectory.existsSync(), true);

          final subDirs = dataDrivenDirectory.listSync().whereType<Directory>();
          expect(subDirs.length, greaterThan(0));

          // Find the most recent app dir (should contain senior_data_scientist)
          final appDir = subDirs.firstWhere(
            (dir) => dir.path.contains('senior_data_scientist'),
            orElse: () =>
                throw Exception('No app dir found for senior_data_scientist'),
          );
          // Check files exist
          final files = appDir.listSync().whereType<File>();
          dirCheckStopwatch.stop();
          logger.info(
            'Directory structure checks completed in ${dirCheckStopwatch.elapsedMilliseconds} ms',
          );
          logger.info('Starting file content checks');
          final fileCheckStopwatch = Stopwatch()..start();
          final resumeFiles = files.where((f) => f.path.contains('resume_'));
          expect(resumeFiles.length, 1);
          expect(resumeFiles.first.existsSync(), true);
          final resumeContent = File(resumeFiles.first.path).readAsStringSync();
          expect(resumeContent, contains('excavator'));
          expect(resumeContent, contains('bulldozer'));
          expect(resumeContent, isNot(contains('Python')));
          expect(resumeContent, isNot(contains('machine learning')));

          final coverFiles = files.where(
            (f) => f.path.contains('cover_letter_'),
          );
          expect(coverFiles.length, 1);
          expect(coverFiles.first.existsSync(), true);
          final coverContent = File(coverFiles.first.path).readAsStringSync();
          expect(coverContent, contains('excavator'));
          expect(coverContent, contains('bulldozer'));
          expect(coverContent, isNot(contains('Python')));
          expect(coverContent, isNot(contains('machine learning')));

          final feedbackFiles = files.where(
            (f) => f.path.contains('feedback_'),
          );
          expect(feedbackFiles.length, 1);
          expect(feedbackFiles.first.existsSync(), true);
          final feedbackContent = File(
            feedbackFiles.first.path,
          ).readAsStringSync();
          expect(feedbackContent, contains('Strengths'));
          expect(feedbackContent, contains('Areas for Improvement'));
          fileCheckStopwatch.stop();
          logger.info(
            'File content checks completed in ${fileCheckStopwatch.elapsedMilliseconds} ms',
          );

          readmeManager.endTest(testName, true);
        } catch (e) {
          readmeManager.endTest(testName, false, error: e.toString());
          rethrow;
        }
      },
      timeout: Timeout(Duration(seconds: 120)),
    );
  });
}
