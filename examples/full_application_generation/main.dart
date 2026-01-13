// ignore_for_file: avoid_print

import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:resumesux_domain/resumesux_domain.dart';
import 'package:resumesux_domain/src/data/data.dart';
import 'package:resumesux_db_sembast/resumesux_db_sembast.dart';
import 'package:resumesux_logging/resumesux_logging.dart';

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
  // It shows how to import applicant data from a digest path.
  // Note: This requires a running AI service for actual generation.

  // Path to the applicant's digest directory containing gigs and assets
  final digestPath = '../../../test/data/digest/software_engineer';

  print('Setting up Logger...');
  final logger = LoggerImpl(name: 'FullApplicationExample');

  print('Setting up AI service...');
  final aiService = AiServiceImpl(
    logger: logger,
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

  final jobReqRepository = JobReqRepositoryImpl(
    logger: logger,
    aiService: aiService,
    applicationDatasource: applicationDatasource,
  );

  final fileRepository = ExampleFileRepository();

  final gigRepository = GigRepositoryImpl(
    logger: logger,
    digestPath: digestPath,
    aiService: aiService,
    applicationDatasource: applicationDatasource,
  );
  final assetRepository = AssetRepositoryImpl(
    logger: logger,
    digestPath: digestPath,
    aiService: aiService,
    applicationDatasource: applicationDatasource,
  );

  final resumeRepository = ResumeRepositoryImpl(
    logger: logger,
    fileRepository: fileRepository,
    applicationDatasource: applicationDatasource,
  );

  final coverLetterRepository = CoverLetterRepositoryImpl(
    logger: logger,
    fileRepository: fileRepository,
    applicationDatasource: applicationDatasource,
  );

  final applicationRepository = ApplicationRepositoryImpl(
    applicationDatasource: applicationDatasource,
    fileRepository: fileRepository,
    resumeRepository: resumeRepository,
    coverLetterRepository: coverLetterRepository,
    feedbackRepository: FeedbackRepositoryImpl(
      logger: logger,
      fileRepository: fileRepository,
      applicationDatasource: applicationDatasource,
    ),
  );

  print('Creating use cases...');
  final generateResumeUsecase = GenerateResumeUsecase(
    logger: logger,
    aiService: aiService,
    resumeRepository: resumeRepository,
  );

  final generateCoverLetterUsecase = GenerateCoverLetterUsecase(
    logger: logger,
    aiService: aiService,
  );

  final generateFeedbackUsecase = GenerateFeedbackUsecase(
    logger: logger,
    aiService: aiService,
    jobReqRepository: jobReqRepository,
    gigRepository: gigRepository,
    assetRepository: assetRepository,
  );

  final saveAiResponsesUsecase = SaveAiResponsesUsecase(
    logger: logger,
    jobReqRepository: jobReqRepository,
    gigRepository: gigRepository,
    assetRepository: assetRepository,
  );

  final generateApplicationUsecase = GenerateApplicationUsecase(
    logger: logger,
    generateResumeUsecase: generateResumeUsecase,
    generateCoverLetterUsecase: generateCoverLetterUsecase,
    generateFeedbackUsecase: generateFeedbackUsecase,
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

  print('Creating basic applicant...');
  final basicApplicant = Applicant(
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

  print('Importing applicant data from digest path...');
  final gigsResult = await gigRepository.getAllGigs();
  if (gigsResult.isLeft()) {
    print('Error loading gigs: ${gigsResult.getLeft()}');
    return;
  }
  final gigs = gigsResult.getOrElse((_) => []);

  final assetsResult = await assetRepository.getAllAssets();
  if (assetsResult.isLeft()) {
    print('Error loading assets: ${assetsResult.getLeft()}');
    return;
  }
  final assets = assetsResult.getOrElse((_) => []);

  final applicant = basicApplicant.copyWith(gigs: gigs, assets: assets);
  print(
    'Applicant data imported successfully. Gigs: ${gigs.length}, Assets: ${assets.length}',
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
