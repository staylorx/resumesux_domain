import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:resumesux_domain/resumesux_domain.dart';

void main() async {
  // This example demonstrates basic resume generation using resumesux_domain.
  // Note: This requires a running AI service (e.g., LM Studio) for actual generation.
  // For demonstration, we'll set up the components.

  print('Setting up AI service...');
  // Using test helper for AI provider
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
    dbName: 'example_applications.db',
  );
  await dbService.initialize();

  final applicationDatasource = ApplicationDatasource(dbService: dbService);

  // For this example, we'll use test data paths
  final digestRepository = DigestRepositoryImpl(
    digestPath: '../../../test/data/digest/software_engineer',
    aiService: aiService,
    applicationDatasource: applicationDatasource,
  );

  final jobReqRepository = JobReqRepositoryImpl(
    aiService: aiService,
    applicationDatasource: applicationDatasource,
  );

  print('Creating use case...');
  final generateResumeUsecase = GenerateResumeUsecase(
    digestRepository: digestRepository,
    aiService: aiService,
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

  print('Generating resume...');
  final result = await generateResumeUsecase.call(
    jobReq: jobReq,
    applicant: applicant,
    prompt: 'Generate a professional resume tailored to this job.',
  );

  if (result.isLeft()) {
    print('Error generating resume: ${result.getLeft()}');
    return;
  }

  final resume = result.getOrElse((_) => throw 'Failed');
  print('Resume generated successfully!');
  print('Resume content length: ${resume.content.length}');
  print('First 500 characters:');
  print(
    resume.content.substring(
      0,
      resume.content.length > 500 ? 500 : resume.content.length,
    ),
  );

  // Clean up
  await dbService.close();
  aiService.httpClient.close();
}
