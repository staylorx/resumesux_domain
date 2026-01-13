// ignore_for_file: avoid_print

import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:resumesux_domain/resumesux_domain.dart';

// Simple file repository for example
class ExampleFileRepository implements FileRepository {
  @override
  Either<Failure, String> readFile({required String path}) {
    return const Right('example file content');
  }

  @override
  Future<Either<Failure, Unit>> writeFile({
    required String path,
    required String content,
  }) async {
    try {
      File(path).writeAsStringSync(content);
      return const Right(unit);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to write file: $e'));
    }
  }

  @override
  Either<Failure, Unit> createDirectory({required String path}) {
    try {
      Directory(path).createSync(recursive: true);
      return const Right(unit);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to create directory: $e'));
    }
  }

  @override
  Either<Failure, Unit> validateDirectory({required String path}) {
    return const Right(unit);
  }

  @override
  Either<Failure, String> createApplicationDirectory({
    required String baseOutputDir,
    required JobReq jobReq,
  }) {
    final companyName = jobReq.concern?.name ?? 'unknown_company';
    final sanitizedCompany = companyName
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
    final concernDir = '$baseOutputDir/$sanitizedCompany';

    final sanitizedTitle = jobReq.title
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final dirName = '${timestamp}_$sanitizedTitle';
    final appDir = '$concernDir/$dirName';

    try {
      Directory(appDir).createSync(recursive: true);
      return Right(appDir);
    } catch (e) {
      return Left(ServiceFailure(message: 'Failed to create app dir: $e'));
    }
  }

  @override
  String getResumeFilePath({required String appDir, required String jobTitle}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$appDir/resume_$timestamp.md';
  }

  @override
  String getCoverLetterFilePath({
    required String appDir,
    required String jobTitle,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$appDir/cover_letter_$timestamp.md';
  }

  @override
  String getFeedbackFilePath({required String appDir}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$appDir/feedback_$timestamp.md';
  }

  @override
  String getAiResponseFilePath({required String appDir, required String type}) {
    final suffix = type == 'jobreq'
        ? '_ai_response.json'
        : '_ai_responses.json';
    return '$appDir/$type$suffix';
  }

  @override
  Future<Either<Failure, Unit>> validateMarkdownFiles({
    required String directory,
    required String fileExtension,
  }) async {
    return const Right(unit);
  }
}

void main() async {
  // This example demonstrates generating a complete job application
  // including resume, cover letter, and feedback using resumesux_domain.
  // Note: This requires a running AI service for actual generation.

  print('Setting up AI service...');
  final aiService = AiServiceImpl(
    httpClient: http.Client(),
    provider: AiProvider(
      name: 'lmstudio',
      url: 'http://127.0.0.1:1234/v1',
      key: 'dummy-key',
      models: [
        AiModel(
          name: 'qwen2.5-7b-instruct',
          isDefault: true,
          settings: {'temperature': 0.8},
        ),
      ],
      defaultModel: AiModel(
        name: 'qwen2.5-7b-instruct',
        isDefault: true,
        settings: {'temperature': 0.8},
      ),
      settings: {'max_tokens': 4000, 'temperature': 0.8},
      isDefault: true,
    ),
  );

  print('Setting up database...');
  final dbService = SembastDatabaseService(
    dbPath: Directory.systemTemp.path,
    dbName: 'full_example_applications.db',
  );
  await dbService.initialize();

  final applicationDatasource = ApplicationDatasource(dbService: dbService);

  print('Setting up repositories...');
  final digestRepository = DigestRepositoryImpl(
    digestPath: '../../../test/data/digest/software_engineer',
    aiService: aiService,
    applicationDatasource: applicationDatasource,
  );

  final jobReqRepository = JobReqRepositoryImpl(
    aiService: aiService,
    applicationDatasource: applicationDatasource,
  );

  final fileRepository = ExampleFileRepository();

  final resumeRepository = ResumeRepositoryImpl(
    fileRepository: fileRepository,
    applicationDatasource: applicationDatasource,
  );

  final coverLetterRepository = CoverLetterRepositoryImpl(
    fileRepository: fileRepository,
    applicationDatasource: applicationDatasource,
  );

  final applicationRepository = ApplicationRepositoryImpl(
    applicationDatasource: applicationDatasource,
    fileRepository: fileRepository,
    resumeRepository: resumeRepository,
    coverLetterRepository: coverLetterRepository,
    feedbackRepository: FeedbackRepositoryImpl(
      fileRepository: fileRepository,
      applicationDatasource: applicationDatasource,
    ),
  );

  print('Creating use cases...');
  final generateResumeUsecase = GenerateResumeUsecase(
    digestRepository: digestRepository,
    aiService: aiService,
    resumeRepository: resumeRepository,
  );

  final generateCoverLetterUsecase = GenerateCoverLetterUsecase(
    digestRepository: digestRepository,
    aiService: aiService,
  );

  final generateFeedbackUsecase = GenerateFeedbackUsecase(
    aiService: aiService,
    jobReqRepository: jobReqRepository,
    gigRepository: digestRepository.gigRepository,
    assetRepository: digestRepository.assetRepository,
  );

  final getDigestUsecase = GetDigestUsecase(
    gigRepository: digestRepository.gigRepository,
    assetRepository: digestRepository.assetRepository,
  );

  final saveAiResponsesUsecase = SaveAiResponsesUsecase(
    jobReqRepository: jobReqRepository,
    gigRepository: digestRepository.gigRepository,
    assetRepository: digestRepository.assetRepository,
  );

  final generateApplicationUsecase = GenerateApplicationUsecase(
    generateResumeUsecase: generateResumeUsecase,
    generateCoverLetterUsecase: generateCoverLetterUsecase,
    generateFeedbackUsecase: generateFeedbackUsecase,
    getDigestUsecase: getDigestUsecase,
    saveAiResponsesUsecase: saveAiResponsesUsecase,
  );

  print('Loading job requirement...');
  final jobReqResult = await jobReqRepository.getJobReq(
    path:
        '../../../test/data/jobreqs/TechInnovate/Software Engineer/job_req.md',
  );

  if (jobReqResult.isLeft()) {
    print('Error loading job req: ${jobReqResult.getLeft()}');
    return;
  }

  final jobReq = jobReqResult.getOrElse((_) => throw 'Failed');

  print('Creating applicant...');
  final applicant = Applicant(
    name: 'Jane Doe',
    preferredName: 'Jane',
    email: 'jane.doe@example.com',
    address: Address(
      street1: '456 Elm St',
      city: 'Somewhere',
      state: 'NY',
      zip: '67890',
    ),
    phone: '(555) 987-6543',
    linkedin: 'https://linkedin.com/in/janedoe',
    github: 'https://github.com/janedoe',
    portfolio: 'https://janedoe.dev',
  );

  print('Generating full application...');
  final result = await generateApplicationUsecase.call(
    jobReq: jobReq,
    applicant: applicant,
    prompt: 'Generate a professional application.',
    includeCover: true,
    includeFeedback: true,
    progress: (message) => print('Progress: $message'),
  );

  if (result.isLeft()) {
    print('Error generating application: ${result.getLeft()}');
    return;
  }

  final application = result.getOrElse((_) => throw 'Failed');
  print('Application generated successfully!');

  // Save the application
  final outputDir = Directory.systemTemp.path;
  final saveResult = await applicationRepository.saveApplicationArtifacts(
    application: application,
    outputDir: outputDir,
  );

  if (saveResult.isLeft()) {
    print('Error saving application: ${saveResult.getLeft()}');
  } else {
    print('Application saved to: $outputDir');
  }

  // Clean up
  await dbService.close();
  aiService.httpClient.close();
}
