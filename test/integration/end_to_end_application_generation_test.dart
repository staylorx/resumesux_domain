import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:resumesux_domain/resumesux_domain.dart';
import 'package:resumesux_db_sembast/resumesux_db_sembast.dart';
import '../test_utils.dart';

void main() {
  late JobReqRepository jobReqRepository;
  late AiService aiService;
  late http.Client httpClient;
  late String suiteDir;
  late Logger logger;
  late SembastDatabaseService dbService;
  late ApplicationRepository applicationRepository;
  late ApplicantRepository applicantRepository;
  late GetConfigUsecase getConfigUsecase;
  late GenerateApplicationUsecase generateApplicationUsecase;
  late TestSuiteReadmeManager readmeManager;

  suiteDir = TestDirFactory.instance.createUniqueTestSuiteDir();
  logger = FileLoggerImpl(
    filePath: '$suiteDir/test_log.txt',
    name: 'EndToEndApplicationGenerationTests',
  );

  readmeManager = TestSuiteReadmeManager(
    suiteDir: suiteDir,
    suiteName: 'End-to-End Application Generation Test',
  );
  readmeManager.initialize();

  setUpAll(() async {
    httpClient = http.Client();
    aiService = createAiServiceImpl(
      logger: logger,
      httpClient: httpClient,
      provider: TestAiHelper.defaultProvider,
    );

    dbService = SembastDatabaseService(
      dbPath: suiteDir,
      dbName: 'end_to_end.db',
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

    final configRepository = createConfigRepositoryImpl(
      logger: logger,
      configDatasource: createConfigDatasource(),
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

    getConfigUsecase = GetConfigUsecase(
      logger: logger,
      configRepository: configRepository,
    );

    final generateResumeUsecase = GenerateResumeUsecase(
      aiService: aiService,
      logger: logger,
      resumeRepository: resumeRepository,
    );

    final generateCoverLetterUsecase = GenerateCoverLetterUsecase(
      aiService: aiService,
      logger: logger,
    );

    final generateFeedbackUsecase = GenerateFeedbackUsecase(
      logger: logger,
      aiService: aiService,
      jobReqRepository: jobReqRepository,
      gigRepository: createGigRepositoryImpl(
        logger: logger,
        digestPath: 'test/data/digest/software_engineer', // will be overridden
        aiService: aiService,
        applicationDatasource: datasource,
      ),
      assetRepository: createAssetRepositoryImpl(
        logger: logger,
        digestPath: 'test/data/digest/software_engineer', // will be overridden
        aiService: aiService,
        applicationDatasource: datasource,
      ),
    );

    final saveAiResponsesUsecase = SaveAiResponsesUsecase(
      jobReqRepository: jobReqRepository,
      gigRepository: createGigRepositoryImpl(
        logger: logger,
        digestPath: 'test/data/digest/software_engineer',
        aiService: aiService,
        applicationDatasource: datasource,
      ),
      assetRepository: createAssetRepositoryImpl(
        logger: logger,
        digestPath: 'test/data/digest/software_engineer',
        aiService: aiService,
        applicationDatasource: datasource,
      ),
      logger: logger,
    );

    generateApplicationUsecase = GenerateApplicationUsecase(
      generateResumeUsecase: generateResumeUsecase,
      generateCoverLetterUsecase: generateCoverLetterUsecase,
      generateFeedbackUsecase: generateFeedbackUsecase,
      saveAiResponsesUsecase: saveAiResponsesUsecase,
      logger: logger,
    );

    logger.info(
      'createApplicantUsecase is declared but not assigned yet - this may cause issues',
    );
  });

  tearDownAll(() async {
    readmeManager.finalize();
    await dbService.close();
    httpClient.close();
  });

  test('End-to-end application generation from config', () async {
    readmeManager.startTest('End-to-end application generation from config');

    try {
      // Step 1: Load config from test config file
      logger.info(
        'Step 1: Loading config from test/data/config/test_config.yaml',
      );
      final configResult = await getConfigUsecase.call(
        configPath: 'test/data/config/test_config.yaml',
      );
      expect(configResult.isRight(), true, reason: 'Failed to load config');
      final config = configResult.getOrElse(
        (failure) =>
            throw Exception('Failed to get config: ${failure.message}'),
      );
      logger.info(
        'Config loaded successfully: digestPath=${config.digestPath}',
      );

      // Step 2: Get applicant from config
      final applicantFromConfig = config.applicant;
      expect(
        applicantFromConfig,
        isNotNull,
        reason: 'Applicant not found in config',
      );
      logger.info('Applicant from config: ${applicantFromConfig.name}');

      // Step 3: Import digest to enrich applicant with gigs and assets
      logger.info('Step 3: Importing digest from ${config.digestPath}');
      final enrichedApplicantResult = await applicantRepository.importDigest(
        applicant: applicantFromConfig,
        digestPath: config.digestPath,
      );
      expect(
        enrichedApplicantResult.isRight(),
        true,
        reason: 'Failed to import digest',
      );
      final enrichedApplicant = enrichedApplicantResult.getOrElse(
        (failure) =>
            throw Exception('Failed to enrich applicant: ${failure.message}'),
      );
      expect(enrichedApplicant.gigs.isNotEmpty, true, reason: 'No gigs loaded');
      expect(
        enrichedApplicant.assets.isNotEmpty,
        true,
        reason: 'No assets loaded',
      );
      logger.info(
        'Applicant enriched with ${enrichedApplicant.gigs.length} gigs and ${enrichedApplicant.assets.length} assets',
      );

      // Step 4: Save applicant to DB
      final createApplicantUsecase = CreateApplicantUseCase(
        repository: applicantRepository,
      );
      logger.info('Step 4: Saving applicant to DB');
      final saveApplicantResult = await createApplicantUsecase.call(
        applicant: enrichedApplicant,
        digestPath: config.digestPath,
      );
      expect(
        saveApplicantResult.isRight(),
        true,
        reason: 'Failed to save applicant to DB',
      );
      logger.info('Applicant saved to DB');

      // Assert applicant in DB
      final datasource = createApplicationDatasource(dbService: dbService);
      final applicantId = sha256
          .convert(utf8.encode(enrichedApplicant.email))
          .toString();
      final applicantDtoResult = await datasource.getApplicant(applicantId);
      expect(
        applicantDtoResult.isRight(),
        true,
        reason: 'Applicant not found in DB after save',
      );
      final applicantDto = applicantDtoResult.getOrElse(
        (_) => throw Exception('Unexpected'),
      );
      expect(
        applicantDto.gigIds.length,
        enrichedApplicant.gigs.length,
        reason: 'Gigs not saved',
      );
      expect(
        applicantDto.assetIds.length,
        enrichedApplicant.assets.length,
        reason: 'Assets not saved',
      );

      // Step 5: Load jobreq (this also saves it to DB)
      const jobReqPath =
          'test/data/jobreqs/TechInnovate/Software Engineer/job_req.md';
      logger.info('Step 5: Loading jobreq from $jobReqPath');
      final jobReqResult = await jobReqRepository.getJobReq(path: jobReqPath);
      expect(jobReqResult.isRight(), true, reason: 'Failed to load jobreq');
      final jobReq = jobReqResult.getOrElse(
        (failure) =>
            throw Exception('Failed to get jobreq: ${failure.message}'),
      );
      logger.info('Jobreq loaded: ${jobReq.title}');

      // Assert jobreq in DB
      final jobReqDocuments = await datasource.getAllDocuments();
      expect(
        jobReqDocuments
            .getOrElse((_) => [])
            .any((doc) => doc.documentType == 'jobreq'),
        true,
        reason: 'Jobreq not saved to DB',
      );

      // Step 6: Generate application
      logger.info('Step 6: Generating application');
      final applicationResult = await generateApplicationUsecase.call(
        jobReq: jobReq,
        applicant: enrichedApplicant,
        prompt: config.customPrompt ?? 'Generate application',
        includeCover: config.includeCover,
        includeFeedback: config.includeFeedback,
        progress: (message) => logger.info(message),
      );
      expect(
        applicationResult.isRight(),
        true,
        reason: 'Failed to generate application',
      );
      final application = applicationResult.getOrElse(
        (failure) => throw Exception(
          'Failed to generate application: ${failure.message}',
        ),
      );
      logger.info('Application generated successfully');

      // Step 7: Save application to DB
      logger.info('Step 7: Saving application to DB');
      final saveAppResult = await applicationRepository.save(
        application: application,
        handle: ApplicationHandle.generate(),
      );
      expect(
        saveAppResult.isRight(),
        true,
        reason: 'Failed to save application to DB',
      );
      logger.info('Application saved to DB');

      // Assert application in DB
      final appsResult = await datasource.getAllApplications();
      expect(
        appsResult.isRight(),
        true,
        reason: 'Failed to retrieve applications from DB',
      );
      final apps = appsResult.getOrElse((_) => []);
      expect(apps.length, 1, reason: 'Application not saved to DB');

      // Step 8: Save application artifacts to file system
      logger.info('Step 8: Saving application artifacts to $suiteDir');
      final saveArtifactsResult = await applicationRepository
          .saveApplicationArtifacts(
            application: application,
            outputDir: suiteDir,
          );
      expect(
        saveArtifactsResult.isRight(),
        true,
        reason: 'Failed to save application artifacts',
      );
      logger.info('Artifacts saved successfully');

      // Assert file outputs
      final allFiles = Directory(
        suiteDir,
      ).listSync(recursive: true).whereType<File>().toList();
      expect(
        allFiles.length,
        greaterThanOrEqualTo(1),
        reason: 'No files created in output directory $suiteDir',
      );
      logger.info('Created ${allFiles.length} files in output directory');

      readmeManager.endTest(
        'End-to-end application generation from config',
        true,
      );
    } catch (e) {
      readmeManager.endTest(
        'End-to-end application generation from config',
        false,
        error: e.toString(),
      );
      rethrow;
    }
  });
}
