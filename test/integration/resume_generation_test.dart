import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

void main() {
  late DigestRepository digestRepository;
  late JobReqRepository jobReqRepository;
  late ApplicationRepository applicationRepository;
  late AiService aiService;
  late GenerateResumeUsecase generateResumeUsecase;
  late GenerateCoverLetterUsecase generateCoverLetterUsecase;
  late GenerateFeedbackUsecase generateFeedbackUsecase;
  late PreprocessJobReqUsecase preprocessJobReqUsecase;
  late GenerateApplicationUsecase generateApplicationUsecase;
  late Logger logger;

  setUpAll(() async {
    // Clear the database before the test group
    final datasource = JobReqSembastDatasource();
    final result = await datasource.clearDatabase();
    expect(
      result.isRight(),
      true,
      reason: 'Failed to clear database before test group',
    );

    // Set up logging
    Logger.root.level = Level.INFO;
    Logger.root.onRecord.listen((record) {
      // ignore: avoid_print
      print(
        '${record.level.name}: ${record.loggerName}: ${record.time}: ${record.message}',
      );
    });
  });

  setUp(() {
    digestRepository = DigestRepositoryImpl(digestPath: 'test/data/digest');
    jobReqRepository = JobReqRepositoryImpl(
      jobReqDatasource: JobReqSembastDatasource(),
    );
    applicationRepository = ApplicationRepositoryImpl();

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

    generateResumeUsecase = GenerateResumeUsecase(
      digestRepository: digestRepository,
      aiService: aiService,
    );

    generateCoverLetterUsecase = GenerateCoverLetterUsecase(
      digestRepository: digestRepository,
      aiService: aiService,
    );

    generateFeedbackUsecase = GenerateFeedbackUsecase(aiService: aiService);

    preprocessJobReqUsecase = PreprocessJobReqUsecase(
      jobReqRepository: jobReqRepository,
      aiService: aiService,
    );

    generateApplicationUsecase = GenerateApplicationUsecase(
      jobReqRepository: jobReqRepository,
      applicationRepository: applicationRepository,
      generateResumeUsecase: generateResumeUsecase,
      generateCoverLetterUsecase: generateCoverLetterUsecase,
      generateFeedbackUsecase: generateFeedbackUsecase,
      preprocessJobReqUsecase: preprocessJobReqUsecase,
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
  });

  test(
    'generate application for Photofax Field Investigator job with correct output path',
    () async {
      // Arrange
      final tempDir = Directory.systemTemp.createTempSync(
        'resumesux_test_output',
      );
      final outputDir = tempDir.path;

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
        jobReqPath: 'test/data/jobreqs/Photofax/Field Investigator.md',
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
      final photofaxDir = Directory('$outputDir/photofax');
      expect(photofaxDir.existsSync(), true);

      final subDirs = photofaxDir.listSync().whereType<Directory>();
      expect(subDirs.length, 1);

      final appDir = subDirs.first;
      expect(appDir.path, contains('field_investigator'));

      // Check files exist
      final resumeFile = File('${appDir.path}/resume_field_investigator.md');
      expect(resumeFile.existsSync(), true);

      // Cleanup
      tempDir.deleteSync(recursive: true);
    },
  );
}
