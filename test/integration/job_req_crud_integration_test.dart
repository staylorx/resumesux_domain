import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:resumesux_domain/resumesux_domain.dart';
import 'package:resumesux_domain/src/data/data.dart';
import 'package:resumesux_db_sembast/resumesux_db_sembast.dart';
import 'package:test_readme_manager/test_readme_manager.dart';
import '../test_utils.dart';

void main() {
  late SembastDatabaseService dbService;
  late ApplicationDatasource datasource;
  late JobReqRepository jobReqRepository;
  late AiService aiService;
  late FileRepository fileRepository;
  late ExtractJobReqFromFileUsecase extractJobReqFromFileUsecase;
  late RemoveJobReqUsecase removeJobReqUsecase;
  late SaveJobReqAiResponseUsecase saveJobReqAiResponseUsecase;
  late String suiteDir;
  late TestSuiteReadmeManager readmeManager;
  late FileLoggerImpl logger;

  setUpAll(() async {
    suiteDir = TestDirFactory.instance.createUniqueTestSuiteDir();

    readmeManager = TestSuiteReadmeManager(
      suiteDir: suiteDir,
      suiteName: 'JobReq CRUD Integration Test',
    );

    logger = FileLoggerImpl(
      filePath: '$suiteDir/test_log.txt',
      name: 'JobReqCrudIntegrationTests',
    );

    dbService = SembastDatabaseService(
      dbPath: suiteDir,
      dbName: 'job_req_crud.db',
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

    fileRepository = createFileRepositoryImpl();

    jobReqRepository = createJobReqRepositoryImpl(
      applicationDatasource: datasource,
      aiService: aiService,
      logger: logger,
    );

    extractJobReqFromFileUsecase = ExtractJobReqFromFileUsecase(
      jobReqRepository: jobReqRepository,
      aiService: aiService,
      fileRepository: fileRepository,
    );

    removeJobReqUsecase = RemoveJobReqUsecase(
      jobReqRepository: jobReqRepository,
      logger: logger,
    );

    saveJobReqAiResponseUsecase = SaveJobReqAiResponseUsecase(
      jobReqRepository: jobReqRepository,
      logger: logger,
    );
  });

  tearDownAll(() async {
    await dbService.close();
    readmeManager.finalize();
  });

  group('JobReq CRUD Integration', () {
    test('Create JobReq from file, persist, and save AI responses', () async {
      final jobReqPath =
          'test/data/jobreqs/ConstuctionPro Builders/Equipment Operator/job_req.md';

      final result = await extractJobReqFromFileUsecase.call(path: jobReqPath);
      final jobReq = result.getOrElse(
        (failure) => throw Exception('Failure: ${failure.message}'),
      );

      // Generate handle and save
      final handle = JobReqHandle.generate();
      final saveResult = await jobReqRepository.save(
        handle: handle,
        jobReq: jobReq,
      );
      expect(saveResult.isRight(), true);

      // Save AI responses
      final aiSaveResult = await saveJobReqAiResponseUsecase.call(
        jobReqId: handle.toString(),
      );
      expect(aiSaveResult.isRight(), true);

      // Verify created
      final getResult = await jobReqRepository.getByHandle(handle: handle);
      expect(getResult.isRight(), true);
      final retrieved = getResult.getOrElse((_) => throw Exception('Failed'));
      expect(retrieved.title, isNotEmpty);
    });

    test('List all JobReqs', () async {
      final result = await jobReqRepository.getAll();
      expect(result.isRight(), true);
      final jobReqs = result.getOrElse((_) => []);
      expect(jobReqs.isNotEmpty, true);
    });

    test('Update JobReq', () async {
      // Get first job req
      final listResult = await jobReqRepository.getAll();
      expect(listResult.isRight(), true);
      final jobReqs = listResult.getOrElse((_) => []);
      expect(jobReqs.isNotEmpty, true);
      final first = jobReqs.first;

      final updatedJobReq = JobReq(
        title: 'Updated Title',
        content: first.jobReq.content,
        contentType: first.jobReq.contentType,
        salary: first.jobReq.salary,
        location: first.jobReq.location,
        concern: first.jobReq.concern,
        createdDate: first.jobReq.createdDate,
        whereFound: first.jobReq.whereFound,
      );

      final updateResult = await jobReqRepository.save(
        handle: first.handle,
        jobReq: updatedJobReq,
      );
      expect(updateResult.isRight(), true);

      // Verify updated
      final getResult = await jobReqRepository.getByHandle(
        handle: first.handle,
      );
      expect(getResult.isRight(), true);
      final retrieved = getResult.getOrElse((_) => throw Exception('Failed'));
      expect(retrieved.title, 'Updated Title');
    });

    test('Remove JobReq', () async {
      // Get first job req
      final listResult = await jobReqRepository.getAll();
      expect(listResult.isRight(), true);
      final jobReqs = listResult.getOrElse((_) => []);
      expect(jobReqs.isNotEmpty, true);
      final first = jobReqs.first;

      final removeResult = await removeJobReqUsecase.call(handle: first.handle);
      expect(removeResult.isRight(), true);

      // Verify removed
      final getResult = await jobReqRepository.getByHandle(
        handle: first.handle,
      );
      expect(getResult.isLeft(), true);
    });
  });
}
