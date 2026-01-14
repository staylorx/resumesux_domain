import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:resumesux_domain/resumesux_domain.dart';
import 'package:resumesux_db_sembast/resumesux_db_sembast.dart';
import '../test_utils.dart';

// Note: Test has a 30-minute timeout to allow graceful stopping.
void main() {
  late JobReqRepository jobReqRepository;
  late AiService aiService;
  late http.Client httpClient;
  late String suiteDir;
  late Logger logger;
  late SembastDatabaseService dbService;
  late ApplicationRepository applicationRepository;
  late ApplicantRepository applicantRepository;
  late TestSuiteManager readmeManager;
  late Config config;

  suiteDir = TestDirFactory.instance.createUniqueTestSuiteDir();

  logger = FileLoggerImpl(
    filePath: '$suiteDir/test_log.txt',
    name: 'AllApplicationsGenerationTests',
  );

  readmeManager = TestSuiteManager(
    suiteDir,
    'All Applications Generation Test GROUPED',
  );

  setUpAll(() async {
    httpClient = http.Client();
    aiService = createAiServiceImpl(
      logger: logger,
      httpClient: httpClient,
      provider: TestAiHelper.defaultProvider,
    );

    // Load config
    final configDatasource = createConfigDatasource();
    final configRepository = createConfigRepositoryImpl(
      logger: logger,
      configDatasource: configDatasource,
    );
    final configResult = await configRepository.loadConfig(
      configPath: 'config.yaml',
    );
    config = configResult.getOrElse(
      (failure) => throw 'Failed to load config: $failure',
    );

    dbService = SembastDatabaseService(
      dbPath: suiteDir,
      dbName: 'applications.db',
    );

    final datasource = createApplicationDatasource(dbService: dbService);
    final result = await datasource.clearJobReqs();
    result.match(
      (failure) => logger.error('Failure: ${failure.message}'),
      (_) => {},
    );
    expect(
      result.isRight(),
      true,
      reason: 'Failed to clear database before test group',
    );

    jobReqRepository = createJobReqRepositoryImpl(
      logger: logger,
      aiService: aiService,
      applicationDatasource: datasource,
    );

    final fileRepository = TestFileRepository();

    final resumeRepository = createResumeRepositoryImpl(
      logger: logger,
      fileRepository: fileRepository,
      applicationDatasource: datasource,
    );
    final coverLetterRepository = createCoverLetterRepositoryImpl(
      logger: logger,
      fileRepository: fileRepository,
      applicationDatasource: datasource,
    );
    final feedbackRepository = createFeedbackRepositoryImpl(
      logger: logger,
      fileRepository: fileRepository,
      applicationDatasource: datasource,
    );

    applicantRepository = createApplicantRepositoryImpl(
      logger: logger,
      applicationDatasource: datasource,
      aiService: aiService,
    );

    applicationRepository = createApplicationRepositoryImpl(
      applicationDatasource: datasource,
      fileRepository: fileRepository,
      resumeRepository: resumeRepository,
      coverLetterRepository: coverLetterRepository,
      feedbackRepository: feedbackRepository,
    );
  });

  tearDownAll(() async {
    readmeManager.finalize();
    await dbService.close();
    httpClient.close();
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

  // personas structure: each persona has name and digestPath
  final personas = [
    {
      'name': 'Equipment Operator',
      'digestPath': 'test/data/digest/heavy_equipment_operator',
    },
    {'name': 'Data Scientist', 'digestPath': 'test/data/digest/data_scientist'},
    {
      'name': 'Software Engineer',
      'digestPath': 'test/data/digest/software_engineer',
    },
  ];

  for (final jobReqPath in allJobReqPaths) {
    // Extract a readable name for the job req, e.g., "ConstuctionPro Builders - Equipment Operator"
    final pathParts = jobReqPath.split('/');
    final company = pathParts[pathParts.length - 3];
    final jobTitle = pathParts[pathParts.length - 2];
    final jobReqName = '$company - $jobTitle';

    String groupName = 'JobReq: $jobReqName';
    group(groupName, () {
      readmeManager.startGroup(groupName);

      for (final persona in personas) {
        final personaName = persona['name'] as String;
        final digestPath = persona['digestPath'] as String;

        group('Persona: $personaName', () {
          late GigRepository gigRepository;
          late AssetRepository assetRepository;
          late Applicant loadedApplicant;
          late GenerateResumeUsecase generateResumeUsecase;
          late GenerateCoverLetterUsecase generateCoverLetterUsecase;
          late GenerateFeedbackUsecase generateFeedbackUsecase;
          late SaveJobReqAiResponseUsecase saveJobReqAiResponseUsecase;
          late SaveGigAiResponseUsecase saveGigAiResponseUsecase;
          late SaveAssetAiResponseUsecase saveAssetAiResponseUsecase;
          late SaveResumeAiResponseUsecase saveResumeAiResponseUsecase;
          late SaveCoverLetterAiResponseUsecase
          saveCoverLetterAiResponseUsecase;
          late SaveFeedbackAiResponseUsecase saveFeedbackAiResponseUsecase;
          late GenerateApplicationUsecase generateApplicationUsecase;

          setUp(() async {
            gigRepository = createGigRepositoryImpl(
              logger: logger,
              digestPath: digestPath,
              aiService: aiService,
              applicationDatasource: createApplicationDatasource(
                dbService: dbService,
              ),
            );

            assetRepository = createAssetRepositoryImpl(
              logger: logger,
              digestPath: digestPath,
              aiService: aiService,
              applicationDatasource: createApplicationDatasource(
                dbService: dbService,
              ),
            );

            // Load applicant with gigs and assets
            final importResult = await applicantRepository.importDigest(
              applicant: applicant,
              digestPath: digestPath,
            );
            loadedApplicant = importResult
                .getOrElse(
                  (failure) => throw Exception(
                    'Failed to import digest: ${failure.message}',
                  ),
                )
                .copyWith(name: '${applicant.name} - $personaName');

            generateResumeUsecase = GenerateResumeUsecase(
              aiService: aiService,
              logger: logger,
              resumeRepository: createResumeRepositoryImpl(
                logger: logger,
                fileRepository: TestFileRepository(),
                applicationDatasource: createApplicationDatasource(
                  dbService: dbService,
                ),
              ),
            );

            generateCoverLetterUsecase = GenerateCoverLetterUsecase(
              aiService: aiService,
              logger: logger,
            );

            generateFeedbackUsecase = GenerateFeedbackUsecase(
              logger: logger,
              aiService: aiService,
              jobReqRepository: jobReqRepository,
              gigRepository: gigRepository,
              assetRepository: assetRepository,
            );

            saveJobReqAiResponseUsecase = SaveJobReqAiResponseUsecase(
              jobReqRepository: jobReqRepository,
              logger: logger,
            );

            saveGigAiResponseUsecase = SaveGigAiResponseUsecase(
              gigRepository: gigRepository,
              logger: logger,
            );

            saveAssetAiResponseUsecase = SaveAssetAiResponseUsecase(
              assetRepository: assetRepository,
              logger: logger,
            );

            saveResumeAiResponseUsecase = SaveResumeAiResponseUsecase(
              resumeRepository: createResumeRepositoryImpl(
                logger: logger,
                fileRepository: TestFileRepository(),
                applicationDatasource: createApplicationDatasource(
                  dbService: dbService,
                ),
              ),
              logger: logger,
            );

            saveCoverLetterAiResponseUsecase = SaveCoverLetterAiResponseUsecase(
              coverLetterRepository: createCoverLetterRepositoryImpl(
                logger: logger,
                fileRepository: TestFileRepository(),
                applicationDatasource: createApplicationDatasource(
                  dbService: dbService,
                ),
              ),
              logger: logger,
            );

            saveFeedbackAiResponseUsecase = SaveFeedbackAiResponseUsecase(
              feedbackRepository: createFeedbackRepositoryImpl(
                logger: logger,
                fileRepository: TestFileRepository(),
                applicationDatasource: createApplicationDatasource(
                  dbService: dbService,
                ),
              ),
              logger: logger,
            );

            generateApplicationUsecase = GenerateApplicationUsecase(
              generateResumeUsecase: generateResumeUsecase,
              generateCoverLetterUsecase: generateCoverLetterUsecase,
              generateFeedbackUsecase: generateFeedbackUsecase,
              saveJobReqAiResponseUsecase: saveJobReqAiResponseUsecase,
              saveGigAiResponseUsecase: saveGigAiResponseUsecase,
              saveAssetAiResponseUsecase: saveAssetAiResponseUsecase,
              saveResumeAiResponseUsecase: saveResumeAiResponseUsecase,
              saveCoverLetterAiResponseUsecase:
                  saveCoverLetterAiResponseUsecase,
              saveFeedbackAiResponseUsecase: saveFeedbackAiResponseUsecase,
              logger: logger,
            );
          });

          String testName =
              '$personaName: Generate application for $jobReqName';
          test(testName, () async {
            readmeManager.startTest(testName);

            try {
              logger.info(
                "Applying for jobreq at $jobReqPath using digest at $digestPath for persona $personaName",
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
                applicant: loadedApplicant,
                config: config,
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

              final handle = ApplicationHandle.generate();
              final saveAppResult = await applicationRepository.save(
                handle: handle,
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
                    config: config,
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
          }, timeout: const Timeout(Duration(minutes: 30)));
        });
      }
    }, skip: true); // Skipping the group for now to avoid long test runs
  }

  group('Verification', () {
    readmeManager.startGroup('Verification');

    String testName = 'Verify all applications saved correctly';
    test(testName, () async {
      readmeManager.startTest(testName);

      try {
        // Assert applications saved to DB
        final datasource = createApplicationDatasource(dbService: dbService);
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
        expect(companyDirs.length, 5, reason: 'Expected 5 company directories');

        // Check that each company directory has the expected substructure
        for (final companyDir in companyDirs) {
          final subDirs = companyDir.listSync().whereType<Directory>().toList();
          logger.info(
            'Company ${companyDir.path.split(Platform.pathSeparator).last} has ${subDirs.length} subdirectories: ${subDirs.map((d) => d.path.split(Platform.pathSeparator).last).toList()}',
          );
          expect(
            subDirs.length,
            3, // 3 applicants per job
            reason:
                'Expected 3 application directories (one per applicant) in ${companyDir.path}',
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
  });
}
