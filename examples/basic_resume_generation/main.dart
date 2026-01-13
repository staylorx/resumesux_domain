// ignore_for_file: avoid_print

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:resumesux_domain/resumesux_domain.dart';
import 'package:resumesux_db_sembast/resumesux_db_sembast.dart';

void main() async {
  // This example demonstrates basic resume generation using resumesux_domain.
  // Note: This requires a running AI service (e.g., LM Studio) for actual generation.
  // For demonstration, we'll set up the components.

  print('Setting up AI service...');
  // Using test helper for AI provider
  final httpClient = http.Client();
  final aiService = createAiServiceImpl(
    httpClient: httpClient,
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

  final applicationDatasource = createApplicationDatasource(
    dbService: dbService,
  );

  final jobReqRepository = createJobReqRepositoryImpl(
    aiService: aiService,
    applicationDatasource: applicationDatasource,
  );

  final resumeRepository = createResumeRepositoryImpl(
    fileRepository: createFileRepositoryImpl(),
    applicationDatasource: applicationDatasource,
  );

  print('Creating use case...');
  final generateResumeUsecase = GenerateResumeUsecase(
    aiService: aiService,
    resumeRepository: resumeRepository,
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
    gigs: [
      Gig(
        title: 'Software Engineer',
        concern: 'StartupXYZ',
        location: 'Remote',
        dates: 'June 2018 - December 2020',
        achievements: [
          'Developed RESTful APIs using Node.js and Express',
          'Built responsive web applications with React',
          'Integrated third-party services and payment gateways',
          'Collaborated with design team for pixel-perfect implementations',
        ],
      ),
      Gig(
        title: 'Senior Software Engineer',
        concern: 'TechCorp',
        location: 'San Francisco, CA',
        dates: 'January 2021 - Present',
        achievements: [
          'Led a team of 5 developers on Flutter mobile app development',
          'Implemented CI/CD pipelines reducing deployment time by 50%',
          'Mentored junior developers and conducted code reviews',
          'Architected microservices using Dart and gRPC',
        ],
      ),
    ],
    assets: [
      Asset(
        content: '''## Skills
- **Languages**: Dart, JavaScript, Python, SQL
- **Frameworks**: Flutter, React, Node.js
- **Tools**: Git, Docker, Firebase, AWS
- **Methodologies**: Agile, TDD, Clean Architecture''',
      ),
      Asset(
        content: '''## Education

### Bachelor of Science in Computer Science
University of California, Berkeley  
*2012 - 2016*

- GPA: 3.8/4.0
- Relevant Coursework: Data Structures, Algorithms, Software Engineering''',
      ),
    ],
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
  httpClient.close();
}
