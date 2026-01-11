import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'package:resumesux_domain/resumesux_domain.dart';
import '../test_utils.dart';

void main() {
  late JobReqRepository jobReqRepository;
  late AiServiceImpl aiService;
  late GenerateFeedbackUsecase generateFeedbackUsecase;
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

    logger = Logger('AllJobReqsGenerationTest');

    suiteDir = TestDirFactory.instance.createUniqueTestSuiteDir();

    // Clear the database before the test group
    final dbService = SembastDatabaseService(
      TestDirFactory.instance.setUpDbPath,
      'applications.db',
    );
    final datasource = ApplicationSembastDatasource(
      dbService: dbService,
      dbPath: TestDirFactory.instance.setUpDbPath,
    );
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
  });

  setUp(() {
    aiService = AiServiceImpl(
      httpClient: http.Client(),
      provider: TestAiHelper.defaultProvider,
    );

    final dbService2 = SembastDatabaseService(
      TestDirFactory.instance.setUpDbPath,
      'applications.db',
    );
    jobReqRepository = JobReqRepositoryImpl(
      aiService: aiService,
      applicationSembastDatasource: ApplicationSembastDatasource(
        dbService: dbService2,
        dbPath: TestDirFactory.instance.setUpDbPath,
      ),
    );

    generateFeedbackUsecase = GenerateFeedbackUsecase(aiService: aiService);

    logger = Logger('AllJobReqsGenerationTest');
  });

  test(
    'generate applications for all jobreqs in test/data/jobreqs',
    () async {
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

      // Generate application for each jobreq
      for (final scenario in scenarios) {
        final scenarioName = scenario['name'] as String;
        final digestPath = scenario['digestPath'] as String;
        final dbService3 = SembastDatabaseService(
          TestDirFactory.instance.setUpDbPath,
          'applications.db',
        );
        final digestRepository = DigestRepositoryImpl(
          digestPath: digestPath,
          aiService: aiService,
          applicationSembastDatasource: ApplicationSembastDatasource(
            dbService: dbService3,
            dbPath: TestDirFactory.instance.setUpDbPath,
          ),
        );

        final getDigestUsecase = GetDigestUsecase(
          gigRepository: digestRepository.gigRepository,
          assetRepository: digestRepository.assetRepository,
        );

        for (final jobReqPath in scenario['jobReqPaths'] as List<String>) {
          logger.info(
            "Applying for jobreq at $jobReqPath using digest at $digestPath for scenario $scenarioName",
          );

          final generateResumeUsecase = GenerateResumeUsecase(
            digestRepository: digestRepository,
            aiService: aiService,
          );

          final generateCoverLetterUsecase = GenerateCoverLetterUsecase(
            digestRepository: digestRepository,
            aiService: aiService,
          );

          final generateApplicationUsecase = GenerateApplicationUsecase(
            generateResumeUsecase: generateResumeUsecase,
            generateCoverLetterUsecase: generateCoverLetterUsecase,
            generateFeedbackUsecase: generateFeedbackUsecase,
            getDigestUsecase: getDigestUsecase,
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
        }
      }

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
    },
    timeout: Timeout.none,
  );
}
