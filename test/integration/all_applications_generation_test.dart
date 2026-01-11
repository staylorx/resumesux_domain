import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:resumesux_domain/resumesux_domain.dart';
import '../test_utils.dart';

void main() {
  late JobReqRepository jobReqRepository;
  late AiServiceImpl aiService;
  late GenerateFeedbackUsecase generateFeedbackUsecase;
  late String suiteDir;
  late Logger logger;
  late SembastDatabaseService dbService;
  late ApplicationRepository applicationRepository;
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

    logger = Logger('AllJobReqsGenerationTest');

    readmeManager = TestSuiteReadmeManager(
      suiteDir: suiteDir,
      suiteName: 'All Applications Generation Test',
    );
    readmeManager.initialize();

    aiService = AiServiceImpl(
      httpClient: http.Client(),
      provider: TestAiHelper.defaultProvider,
    );

    dbService = SembastDatabaseService(
      dbPath: suiteDir,
      dbName: 'applications.db',
    );

    final datasource = ApplicationDatasource(dbService: dbService);
    final result = await datasource.clearJobReqs();
    result.fold(
      (failure) => logger.severe('Failure: ${failure.message}'),
      (_) => {},
    );
    expect(
      result.isRight(),
      true,
      reason: 'Failed to clear database before test group',
    );

    jobReqRepository = JobReqRepositoryImpl(
      aiService: aiService,
      applicationDatasource: datasource,
    );

    generateFeedbackUsecase = GenerateFeedbackUsecase(aiService: aiService);

    final fileRepository = TestFileRepository();

    final resumeRepository = ResumeRepositoryImpl(
      fileRepository: fileRepository,
      applicationDatasource: datasource,
    );
    final coverLetterRepository = CoverLetterRepositoryImpl(
      fileRepository: fileRepository,
      applicationDatasource: datasource,
    );
    final feedbackRepository = FeedbackRepositoryImpl(
      fileRepository: fileRepository,
      applicationDatasource: datasource,
    );

    applicationRepository = ApplicationRepositoryImpl(
      applicationDatasource: datasource,
      fileRepository: fileRepository,
      resumeRepository: resumeRepository,
      coverLetterRepository: coverLetterRepository,
      feedbackRepository: feedbackRepository,
    );
  });

  tearDownAll(() {
    readmeManager.finalize();
  });

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

  // list of all jobreq paths
  final allJobReqPaths = [
    'test/data/jobreqs/ConstuctionPro Builders/Equipment Operator/job_req.md',
    'test/data/jobreqs/DataDriven Analytics/Senior Data Scientist/job_req.md',
    'test/data/jobreqs/StartupBoost/Flutter App Developer/software_engineer.md',
    'test/data/jobreqs/TechInnovate/Software Engineer/job_req.md',
    'test/data/jobreqs/TelecomPlus/Customer Churn Prediction Model Development/data_scientist.md',
  ];

  // scenarios structure: each scenario has name, digestPath, and jobReqPaths
  final scenarios = [
    {
      'name': 'Equipment Operator',
      'digestPath': 'test/data/digest/heavy_equipment_operator',
      'jobReqPaths': allJobReqPaths,
    },
    {
      'name': 'Data Scientist',
      'digestPath': 'test/data/digest/data_scientist',
      'jobReqPaths': allJobReqPaths,
    },
    {
      'name': 'Software Engineer',
      'digestPath': 'test/data/digest/software_engineer',
      'jobReqPaths': allJobReqPaths,
    },
  ];

  for (final scenario in scenarios) {
    final scenarioName = scenario['name'] as String;
    final digestPath = scenario['digestPath'] as String;
    final jobReqPaths = scenario['jobReqPaths'] as List<String>;

    group('Scenario: $scenarioName', () {
      readmeManager.startGroup('Scenario: $scenarioName');

      late DigestRepository digestRepository;
      late GetDigestUsecase getDigestUsecase;
      late GenerateResumeUsecase generateResumeUsecase;
      late GenerateCoverLetterUsecase generateCoverLetterUsecase;
      late GenerateApplicationUsecase generateApplicationUsecase;

      setUp(() {
        digestRepository = DigestRepositoryImpl(
          digestPath: digestPath,
          aiService: aiService,
          applicationDatasource: ApplicationDatasource(dbService: dbService),
        );

        getDigestUsecase = GetDigestUsecase(
          gigRepository: digestRepository.gigRepository,
          assetRepository: digestRepository.assetRepository,
        );

        generateResumeUsecase = GenerateResumeUsecase(
          digestRepository: digestRepository,
          aiService: aiService,
        );

        generateCoverLetterUsecase = GenerateCoverLetterUsecase(
          digestRepository: digestRepository,
          aiService: aiService,
        );

        generateApplicationUsecase = GenerateApplicationUsecase(
          generateResumeUsecase: generateResumeUsecase,
          generateCoverLetterUsecase: generateCoverLetterUsecase,
          generateFeedbackUsecase: generateFeedbackUsecase,
          getDigestUsecase: getDigestUsecase,
        );
      });

      for (final jobReqPath in jobReqPaths) {
        test('Generate application for $jobReqPath', () async {
          final testName = 'Generate application for $jobReqPath';
          readmeManager.startTest(testName);

          try {
            logger.info(
              "Applying for jobreq at $jobReqPath using digest at $digestPath for scenario $scenarioName",
            );

            final jobReqResult = await jobReqRepository.getJobReq(
              path: jobReqPath,
            );
            final jobReq = jobReqResult.getOrElse(
              (failure) => throw Exception(
                'Failed to get jobreq at $jobReqPath: ${failure.message}',
              ),
            );

            final result = await generateApplicationUsecase.call(
              jobReq: jobReq,
              applicant: applicant,
              prompt: 'Generate a professional application.',
              includeCover: true,
              includeFeedback: true,
              progress: (message) => logger.info(message),
            );

            expect(
              result.isRight(),
              true,
              reason: 'Failed to generate application for $jobReqPath',
            );

            final application = result.getOrElse(
              (_) => throw Exception('Failed to generate application'),
            );

            final saveAppResult = await applicationRepository.saveApplication(
              application: application,
            );
            expect(
              saveAppResult.isRight(),
              true,
              reason: 'Failed to save application to DB for $jobReqPath',
            );

            final saveArtifactsResult = await applicationRepository
                .saveApplicationArtifacts(
                  application: application,
                  outputDir: suiteDir,
                );
            expect(
              saveArtifactsResult.isRight(),
              true,
              reason: 'Failed to save application artifacts for $jobReqPath',
            );

            readmeManager.endTest(testName, true);
          } catch (e) {
            readmeManager.endTest(testName, false, error: e.toString());
            rethrow;
          }
        }, timeout: Timeout.none);
      }
    });
  }

  test('Verify all applications saved correctly', () async {
    final testName = 'Verify all applications saved correctly';
    readmeManager.startTest(testName);

    try {
      // Assert applications saved to DB
      final datasource = ApplicationDatasource(dbService: dbService);
      final appsResult = await datasource.getAllApplications();
      expect(
        appsResult.isRight(),
        true,
        reason: 'Failed to retrieve applications from DB',
      );
      final apps = appsResult.getOrElse((_) => []);
      expect(
        apps.length,
        15, // 3 scenarios * 5 jobreqs
        reason: 'Expected 15 applications in DB, found ${apps.length}',
      );

      // Assert that output directory structure is correct
      final outputDirectory = Directory(suiteDir);
      expect(outputDirectory.existsSync(), true);

      final companyDirs = outputDirectory
          .listSync()
          .whereType<Directory>()
          .toList();
      logger.info(
        'Found ${companyDirs.length} company directories: ${companyDirs.map((d) => d.path.split(Platform.pathSeparator).last).toList()}',
      );
      expect(companyDirs.length, 6, reason: 'Expected 6 company directories');

      // Check that each company directory has the expected substructure
      for (final companyDir in companyDirs) {
        final subDirs = companyDir.listSync().whereType<Directory>().toList();
        logger.info(
          'Company ${companyDir.path.split(Platform.pathSeparator).last} has ${subDirs.length} subdirectories: ${subDirs.map((d) => d.path.split(Platform.pathSeparator).last).toList()}',
        );
        expect(
          subDirs.length,
          greaterThanOrEqualTo(1),
          reason:
              'Expected at least 1 application directory in ${companyDir.path}',
        );

        final appDir = subDirs.first;
        final files = appDir.listSync().whereType<File>().toList();
        expect(
          files.length,
          greaterThanOrEqualTo(1),
          reason: 'Expected at least 1 file in ${appDir.path}',
        );

        // Check for resume file
        final resumeFiles = files
            .where((file) => file.path.contains('resume_'))
            .toList();
        expect(
          resumeFiles.length,
          1,
          reason: 'Expected 1 resume file in ${appDir.path}',
        );
        expect(resumeFiles.first.existsSync(), true);
      }

      readmeManager.endTest(testName, true);
    } catch (e) {
      readmeManager.endTest(testName, false, error: e.toString());
      rethrow;
    }
  });
}
