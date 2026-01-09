import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:resume_suckage_domain/resume_suckage_domain.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('http://example.com'));
    registerFallbackValue(<String, String>{});
    registerFallbackValue(<String, dynamic>{});
  });

  late MockHttpClient mockHttpClient;
  late DigestRepository digestRepository;
  late JobReqRepository jobReqRepository;
  late AiService aiService;
  late GenerateResumeUsecase generateResumeUsecase;
  late GenerateCoverLetterUsecase generateCoverLetterUsecase;

  setUp(() {
    mockHttpClient = MockHttpClient();
    digestRepository = DigestRepositoryImpl(digestPath: 'digest');
    jobReqRepository = JobReqRepositoryImpl();

    // Mock the HTTP response for AI generation
    when(() => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        )).thenAnswer((_) async => http.Response(
          '{"choices": [{"message": {"content": "# John Doe\\n\\n## Professional Summary\\nExperienced software engineer...\\n\\n## Skills\\n- Dart\\n- Flutter\\n\\n## Experience\\n- Senior Software Engineer at TechCorp\\n"}}]}',
          200,
        ));

    final dummyProvider = AiProvider(
      id: 'lmstudio',
      url: 'http://127.0.0.1:1234',
      key: 'dummy-key',
      models: [],
      settings: {'max_tokens': 4000, 'temperature': 0.7},
    );

    final model = AiModel(
      name: 'qwen/qwen2.5-coder-14b',
      provider: dummyProvider,
      isDefault: true,
    );

    final provider = AiProvider(
      id: 'lmstudio',
      url: 'http://127.0.0.1:1234',
      key: 'dummy-key',
      models: [model],
      defaultModel: model,
      settings: {'max_tokens': 4000, 'temperature': 0.7},
    );

    aiService = AiService(httpClient: mockHttpClient, provider: provider);

    generateResumeUsecase = GenerateResumeUsecase(
      digestRepository: digestRepository,
      aiService: aiService,
    );

    generateCoverLetterUsecase = GenerateCoverLetterUsecase(
      digestRepository: digestRepository,
      aiService: aiService,
    );
  });

  test('generate resume for software engineer job', () async {
    // Arrange
    final jobReqResult = await jobReqRepository.getJobReq(path: 'digest/software_engineer/job_req.md');
    expect(jobReqResult.isRight(), true);
    final jobReq = jobReqResult.getOrElse((_) => throw Exception('Failed to load job req'));

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
    final resume = result.getOrElse((_) => throw Exception('Failed to generate resume'));
    expect(resume.content, isNotEmpty);
    expect(resume.content, contains('John Doe'));
    expect(resume.content, contains('Professional Summary'));
  });

  test('generate cover letter for data scientist job', () async {
    // Arrange
    final jobReqResult = await jobReqRepository.getJobReq(path: 'digest/data_scientist/job_req.md');
    expect(jobReqResult.isRight(), true);
    final jobReq = jobReqResult.getOrElse((_) => throw Exception('Failed to load job req'));

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
    final coverLetter = result.getOrElse((_) => throw Exception('Failed to generate cover letter'));
    expect(coverLetter.content, isNotEmpty);
    expect(coverLetter.content, contains('John Doe'));
  });
}