import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:resumesux_domain/resumesux_domain.dart';
import 'package:resumesux_domain/src/data/data.dart';
import 'package:resumesux_db_sembast/resumesux_db_sembast.dart';
import '../test_utils.dart';

void main() {
  late SembastDatabaseService dbService;
  late ApplicationDatasource datasource;
  late ApplicantRepository applicantRepository;
  late AiService aiService;
  late CreateApplicantUseCase createApplicantUseCase;
  late GetApplicantUsecase getApplicantUsecase;
  late GetAllApplicantsUsecase getAllApplicantsUsecase;
  late UpdateApplicantUsecase updateApplicantUsecase;
  late RemoveApplicantUsecase removeApplicantUsecase;
  late String suiteDir;
  late TestSuiteReadmeManager readmeManager;
  late FileLoggerImpl logger;

  setUpAll(() async {
    suiteDir = TestDirFactory.instance.createUniqueTestSuiteDir();

    readmeManager = TestSuiteReadmeManager(
      suiteDir: suiteDir,
      suiteName: 'Applicant CRUD Integration Test',
    );

    logger = FileLoggerImpl(
      filePath: '$suiteDir/test_log.txt',
      name: 'ApplicantCrudIntegrationTests',
    );

    dbService = SembastDatabaseService(
      dbPath: suiteDir,
      dbName: 'applicant_crud.db',
    );

    datasource = createApplicationDatasource(dbService: dbService);

    // Set up AI service with real HTTP
    final configDatasource = createConfigDatasource();
    final configRepository = createConfigRepositoryImpl(
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

    applicantRepository = createApplicantRepositoryImpl(
      applicationDatasource: datasource,
      aiService: aiService,
      logger: logger,
    );

    createApplicantUseCase = CreateApplicantUseCase(
      repository: applicantRepository,
    );

    getApplicantUsecase = GetApplicantUsecase(
      applicantRepository: applicantRepository,
      logger: logger,
    );

    getAllApplicantsUsecase = GetAllApplicantsUsecase(
      applicantRepository: applicantRepository,
      logger: logger,
    );

    updateApplicantUsecase = UpdateApplicantUsecase(
      applicantRepository: applicantRepository,
      logger: logger,
    );

    removeApplicantUsecase = RemoveApplicantUsecase(
      applicantRepository: applicantRepository,
      logger: logger,
    );
  });

  tearDownAll(() async {
    await dbService.close();
    readmeManager.finalize();
  });

  group('Applicant CRUD Integration', () {
    test('Create Applicant with digest import', () async {
      final applicant = Applicant(name: 'John Doe', email: 'john@example.com');

      final digestPath = 'test/data/digest/software_engineer';

      final result = await createApplicantUseCase.call(
        applicant: applicant,
        digestPath: digestPath,
      );
      final handle = result.getOrElse(
        (failure) => throw Exception('Failure: ${failure.message}'),
      );

      // Verify created
      final getResult = await getApplicantUsecase.call(handle);
      expect(getResult.isRight(), true);
      final retrieved = getResult.getOrElse((_) => throw Exception('Failed'));
      expect(retrieved.name, 'John Doe');
      expect(retrieved.gigs.length, 3);
      expect(retrieved.assets.length, 6);
    });

    test('List all Applicants', () async {
      final result = await getAllApplicantsUsecase.call();
      expect(result.isRight(), true);
      final applicants = result.getOrElse((_) => []);
      expect(applicants.isNotEmpty, true);
    });

    test('Update Applicant', () async {
      // Get first applicant
      final listResult = await getAllApplicantsUsecase.call();
      expect(listResult.isRight(), true);
      final applicants = listResult.getOrElse((_) => []);
      expect(applicants.isNotEmpty, true);
      final first = applicants.first;

      final updatedApplicant = first.applicant.copyWith(name: 'Updated Name');

      final updateResult = await updateApplicantUsecase.call(
        handle: first.handle,
        applicant: updatedApplicant,
      );
      expect(updateResult.isRight(), true);

      // Verify updated
      final getResult = await getApplicantUsecase.call(first.handle);
      expect(getResult.isRight(), true);
      final retrieved = getResult.getOrElse((_) => throw Exception('Failed'));
      expect(retrieved.name, 'Updated Name');
    });

    test('Remove Applicant', () async {
      // Get first applicant
      final listResult = await getAllApplicantsUsecase.call();
      expect(listResult.isRight(), true);
      final applicants = listResult.getOrElse((_) => []);
      expect(applicants.isNotEmpty, true);
      final first = applicants.first;

      final removeResult = await removeApplicantUsecase.call(
        handle: first.handle,
      );
      expect(removeResult.isRight(), true);

      // Verify removed
      final getResult = await getApplicantUsecase.call(first.handle);
      expect(getResult.isLeft(), true);
    });
  });
}
