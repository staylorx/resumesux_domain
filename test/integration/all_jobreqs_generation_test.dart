import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'package:resumesux_domain/resumesux_domain.dart';
import '../test_utils.dart';

void main() {
  late DigestRepository digestRepository;
  late JobReqRepository jobReqRepository;
  late ApplicationRepository applicationRepository;
  late AiService aiService;
  late GenerateResumeUsecase generateResumeUsecase;
  late GenerateCoverLetterUsecase generateCoverLetterUsecase;
  late GenerateFeedbackUsecase generateFeedbackUsecase;
  late CreateJobReqUsecase createJobReqUsecase;
  late GenerateApplicationUsecase generateApplicationUsecase;
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

    // Clear the database before the test group
    final datasource = JobReqSembastDatasource(
      dbPath: TempDirFactory.instance.setUpDbPath,
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
    final model = AiModel(
      name: 'qwen/qwen2.5-coder-14b',
      isDefault: true,
      settings: {'temperature': 0.8},
    );

    final provider = AiProvider(
      id: 'lmstudio',
      url: 'http://127.0.0.1:1234/v1',
      key: 'dummy-key',
      models: [model],
      defaultModel: model,
      settings: {'max_tokens': 4000, 'temperature': 0.8},
      isDefault: true,
    );

    aiService = AiService(httpClient: http.Client(), provider: provider);

    digestRepository = DigestRepositoryImpl(digestPath: 'test/data/digest');
    jobReqRepository = JobReqRepositoryImpl(
      jobReqDatasource: JobReqSembastDatasource(
        dbPath: TempDirFactory.instance.setUpDbPath,
      ),
      fileJobReqDatasource: FileJobReqDatasourceImpl(),
    );
    applicationRepository = ApplicationRepositoryImpl();

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
    );

    generateApplicationUsecase = GenerateApplicationUsecase(
      jobReqRepository: jobReqRepository,
      applicationRepository: applicationRepository,
      generateResumeUsecase: generateResumeUsecase,
      generateCoverLetterUsecase: generateCoverLetterUsecase,
      generateFeedbackUsecase: generateFeedbackUsecase,
      createJobReqUsecase: createJobReqUsecase,
    );

    logger = Logger('AllJobReqsGenerationTest');
  });

  test(
    'generate applications for all jobreqs in test/data/jobreqs',
    () async {
      final outputDir = TempDirFactory.instance.outputDir;

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

      // List of all jobreq paths
      final jobReqPaths = [
        'test/data/jobreqs/ConstuctionPro Builders/Equipment Operator/job_req.md',
        'test/data/jobreqs/DataDriven Analytics/Senior Data Scientist/job_req.md',
        'test/data/jobreqs/StartupBoost/Flutter App Developer/software_engineer.md',
        'test/data/jobreqs/TechInnovate/Software Engineer/job_req.md',
        'test/data/jobreqs/TelecomPlus/Customer Churn Prediction Model Development/data_scientist.md',
      ];

      // Generate application for each jobreq
      for (final jobReqPath in jobReqPaths) {
        final result = await generateApplicationUsecase.call(
          jobReqPath: jobReqPath,
          applicant: applicant,
          prompt: 'Generate a professional application.',
          outputDir: outputDir,
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

      // Assert that output directory structure is correct
      final outputDirectory = Directory(outputDir);
      expect(outputDirectory.existsSync(), true);

      final companyDirs = outputDirectory
          .listSync()
          .whereType<Directory>()
          .toList();
      expect(companyDirs.length, 5, reason: 'Expected 5 company directories');

      // Check that each company directory has the expected substructure
      for (final companyDir in companyDirs) {
        final subDirs = companyDir.listSync().whereType<Directory>().toList();
        expect(
          subDirs.length,
          1,
          reason: 'Expected 1 application directory in ${companyDir.path}',
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
