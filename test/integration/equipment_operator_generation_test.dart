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
  late GetDigestUsecase getDigestUsecase;
  late GenerateApplicationUsecase generateApplicationUsecase;
  late FileRepository fileRepository;
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

    logger = Logger('ResumeHeavyEquipmentOperatorGenerationTest');

    suiteDir = TestDirFactory.instance.createUniqueTestSuiteDir();

    // Clear the database before the test group
    final datasource = ApplicationSembastDatasource(
      dbPath: TestDirFactory.instance.setUpAllDbPath,
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

    fileRepository = TestFileRepository();

    final applicationSembastDatasource = ApplicationSembastDatasource(
      dbPath: TestDirFactory.instance.setUpDbPath,
    );

    digestRepository = DigestRepositoryImpl(
      digestPath: 'test/data/digest/heavy_equipment_operator',
      aiService: aiService,
      applicationSembastDatasource: applicationSembastDatasource,
    );
    jobReqRepository = JobReqRepositoryImpl(
      aiService: aiService,
      applicationSembastDatasource: applicationSembastDatasource,
    );
    resumeRepository = ResumeRepositoryImpl(
      fileRepository: fileRepository,
      applicationSembastDatasource: applicationSembastDatasource,
    );
    coverLetterRepository = CoverLetterRepositoryImpl(
      fileRepository: fileRepository,
      applicationSembastDatasource: applicationSembastDatasource,
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

  /// purposefully wierd application of operator to data science job req
  test('generate resume for heavy equipment operator job', () async {
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
  });

  test('generate cover letter for heavy equipment operator job', () async {
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
  });

  test(
    'generate application for DataDriven Analytics Senior Data Scientist job with heavy equipment operator data',
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

      final jobReqResult = await jobReqRepository.getJobReq(
        path:
            'test/data/jobreqs/DataDriven Analytics/Senior Data Scientist/job_req.md',
      );
      final jobReq = jobReqResult.getOrElse(
        (_) => throw Exception('Failed to load job req'),
      );

      // Act
      final result = await generateApplicationUsecase.call(
        jobReq: jobReq,
        applicant: applicant,
        prompt: 'Generate a professional application.',
        includeCover: true,
        includeFeedback: true,
        progress: (message) => logger.info(message),
      );

      // Assert
      expect(result.isRight(), true);

      // Check that output directory structure is correct
      final dataDrivenDirectory = Directory('$suiteDir/datadriven_analytics');
      expect(dataDrivenDirectory.existsSync(), true);

      final subDirs = dataDrivenDirectory.listSync().whereType<Directory>();
      expect(subDirs.length, greaterThan(0));

      // Find the most recent app dir (should contain heavy_equipment_operator)
      final appDir = subDirs.firstWhere(
        (dir) => dir.path.contains('heavy_equipment_operator'),
        orElse: () =>
            throw Exception('No app dir found for heavy_equipment_operator'),
      );
      // Check files exist
      final files = appDir.listSync().whereType<File>();
      final resumeFiles = files.where((f) => f.path.contains('resume_'));
      expect(resumeFiles.length, 1);
      expect(resumeFiles.first.existsSync(), true);
      final resumeContent = File(resumeFiles.first.path).readAsStringSync();
      expect(resumeContent, contains('excavator'));
      expect(resumeContent, contains('bulldozer'));
      expect(resumeContent, isNot(contains('Python')));
      expect(resumeContent, isNot(contains('machine learning')));

      final coverFiles = files.where((f) => f.path.contains('cover_letter_'));
      expect(coverFiles.length, 1);
      expect(coverFiles.first.existsSync(), true);
      final coverContent = File(coverFiles.first.path).readAsStringSync();
      expect(coverContent, contains('excavator'));
      expect(coverContent, contains('bulldozer'));
      expect(coverContent, isNot(contains('Python')));
      expect(coverContent, isNot(contains('machine learning')));

      final feedbackFiles = files.where((f) => f.path.contains('feedback_'));
      expect(feedbackFiles.length, 1);
      expect(feedbackFiles.first.existsSync(), true);
      final feedbackContent = File(feedbackFiles.first.path).readAsStringSync();
      expect(feedbackContent, contains('not qualified'));
      expect(feedbackContent, contains('lacks'));
    },
    timeout: Timeout(Duration(seconds: 120)),
  );
}
