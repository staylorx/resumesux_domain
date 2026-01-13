import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:resumesux_domain/resumesux_domain.dart';
import 'package:resumesux_domain/src/data/data.dart';
import 'package:resumesux_db_sembast/resumesux_db_sembast.dart';
import '../test_utils.dart';

void main() {
  late SembastDatabaseService dbService;
  late ApplicationDatasource datasource;
  late ApplicantRepositoryImpl repository;
  late String suiteDir;
  late AiService aiService;
  late ConfigRepository configRepository;
  late ConfigDatasource configDatasource;

  setUpAll(() async {
    suiteDir = TestDirFactory.instance.createUniqueTestSuiteDir();

    // Set up AI service with real HTTP
    configDatasource = createConfigDatasource();
    configRepository = createConfigRepositoryImpl(
      configDatasource: configDatasource,
    );
    final providerResult = await configRepository.getProvider(
      providerName: 'lmstudio',
      configPath: 'test/data/config/valid_config.yaml',
    );
    expect(providerResult.isRight(), true);
    final provider = providerResult.getOrElse(
      (_) => throw Exception('Failed to get provider'),
    );
    aiService = createAiServiceImpl(
      httpClient: http.Client(),
      provider: provider,
    );

    dbService = SembastDatabaseService(dbPath: suiteDir, dbName: 'test.db');
    datasource = ApplicationDatasource(dbService: dbService);
    repository = ApplicantRepositoryImpl(
      applicationDatasource: datasource,
      aiService: aiService,
    );
  });

  tearDownAll(() async {
    await dbService.close();
    // Clean up suite directory after tests
    final suiteDirectory = Directory(suiteDir);
    if (suiteDirectory.existsSync()) {
      suiteDirectory.deleteSync(recursive: true);
    }
  });

  group('Applicant Repository Integration', () {
    test('save and get applicant with gigs and assets', () async {
      final applicant = Applicant(
        name: 'John Doe',
        email: 'john@example.com',
        gigs: [
          Gig(
            title: 'Software Engineer',
            concern: 'TechCorp',
            location: 'SF',
            dates: '2020-2023',
            achievements: ['Built app', 'Led team'],
          ),
        ],
        assets: [Asset(content: 'Bachelor of Science in CS')],
      );

      final handle = ApplicantHandle.generate();

      // Save
      final saveResult = await repository.save(
        handle: handle,
        applicant: applicant,
      );
      expect(saveResult.isRight(), true);

      // Get
      final getResult = await repository.getByHandle(handle: handle);
      expect(getResult.isRight(), true);
      final retrieved = getResult.getOrElse((_) => throw Exception('Failed'));
      expect(retrieved.name, 'John Doe');
      expect(retrieved.email, 'john@example.com');
      expect(retrieved.gigs.length, 1);
      expect(retrieved.gigs.first.title, 'Software Engineer');
      expect(retrieved.assets.length, 1);
      expect(retrieved.assets.first.content, 'Bachelor of Science in CS');
    });

    test('get all applicants', () async {
      final applicant2 = Applicant(
        name: 'Jane Smith',
        email: 'jane@example.com',
      );
      final handle2 = ApplicantHandle.generate();
      await repository.save(handle: handle2, applicant: applicant2);

      final getAllResult = await repository.getAll();
      expect(getAllResult.isRight(), true);
      final applicants = getAllResult.getOrElse((_) => []);
      expect(
        applicants.length >= 2,
        true,
      ); // Allow for more if tests run multiple times
      expect(applicants.any((a) => a.applicant.name == 'John Doe'), true);
      expect(applicants.any((a) => a.applicant.name == 'Jane Smith'), true);
    });

    test('remove applicant', () async {
      final handle = ApplicantHandle.generate();
      final applicant = Applicant(
        name: 'To Remove',
        email: 'remove@example.com',
      );
      await repository.save(handle: handle, applicant: applicant);

      // Verify saved
      final getBefore = await repository.getByHandle(handle: handle);
      expect(getBefore.isRight(), true);

      // Remove
      final removeResult = await repository.remove(handle: handle);
      expect(removeResult.isRight(), true);

      // Verify removed
      final getAfter = await repository.getByHandle(handle: handle);
      expect(getAfter.isLeft(), true);
    });
  });
}
