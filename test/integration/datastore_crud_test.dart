import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:resumesux_domain/src/data/data.dart';
import 'package:resumesux_domain/src/domain/factories/factories.dart';
import 'package:resumesux_db_sembast/resumesux_db_sembast.dart';

void main() {
  late SembastDatabaseService dbService;
  late ApplicationDatasource datasource;
  final dbPath = 'build/test_datastore';

  setUpAll(() async {
    // Ensure build directory exists
    final buildDir = Directory('build');
    if (!buildDir.existsSync()) {
      buildDir.createSync(recursive: true);
    }

    dbService = SembastDatabaseService(dbPath: dbPath, dbName: 'test.db');

    datasource = createApplicationDatasource(dbService: dbService);
  });

  tearDownAll(() async {
    await dbService.close();
    // Clean up build directory after tests
    final buildDir = Directory(dbPath);
    if (buildDir.existsSync()) {
      buildDir.deleteSync(recursive: true);
    }
  });

  group('Application CRUD', () {
    test('save and get application', () async {
      final dto = ApplicationDto(
        id: 'test_app_1',
        applicantId: 'applicant_1',
        jobReqId: 'jobreq_1',
      );

      // Save
      final saveResult = await datasource.saveApplication(dto);
      expect(saveResult.isRight(), true);

      // Get
      final getResult = await datasource.getApplication('test_app_1');
      expect(getResult.isRight(), true);
      final retrieved = getResult.getOrElse((_) => throw Exception('Failed'));
      expect(retrieved.id, 'test_app_1');
      expect(retrieved.applicantId, 'applicant_1');
      expect(retrieved.jobReqId, 'jobreq_1');
    });

    test('get all applications', () async {
      // Add another
      final dto2 = ApplicationDto(
        id: 'test_app_2',
        applicantId: 'applicant_2',
        jobReqId: 'jobreq_2',
      );
      await datasource.saveApplication(dto2);

      final getAllResult = await datasource.getAllApplications();
      expect(getAllResult.isRight(), true);
      final apps = getAllResult.getOrElse((_) => []);
      expect(apps.length, 2);
      expect(apps.any((a) => a.id == 'test_app_1'), true);
      expect(apps.any((a) => a.id == 'test_app_2'), true);
    });
  });

  group('Document CRUD', () {
    test('save and get resume document', () async {
      final dto = DocumentDto(
        id: 'resume_1',
        content: 'Resume content',
        contentType: 'text/markdown',
        aiResponseJson: '{"model": "test"}',
        documentType: 'resume',
        jobReqId: 'jobreq_1',
      );

      // Save
      final saveResult = await datasource.saveDocument(dto);
      expect(saveResult.isRight(), true);

      // Get
      final getResult = await datasource.getDocument('resume_1', 'resume');
      expect(getResult.isRight(), true);
      final retrieved = getResult.getOrElse((_) => throw Exception('Failed'));
      expect(retrieved.id, 'resume_1');
      expect(retrieved.content, 'Resume content');
      expect(retrieved.documentType, 'resume');
    });

    test('save and get jobreq document with concern VO', () async {
      final jobReqDto = JobReqDto(
        id: 'jobreq_1',
        title: 'Software Engineer',
        content: 'Job description',
        concern: {
          'name': 'TechCorp',
          'description': 'Tech company',
          'location': 'SF',
        },
      );

      final dto = DocumentDto(
        id: jobReqDto.id,
        content: 'Job description',
        contentType: 'text/markdown',
        aiResponseJson: jsonEncode(jobReqDto.toMap()),
        documentType: 'jobreq',
      );

      // Save
      final saveResult = await datasource.saveDocument(dto);
      expect(saveResult.isRight(), true);

      // Get
      final getResult = await datasource.getDocument('jobreq_1', 'jobreq');
      expect(getResult.isRight(), true);
      final retrieved = getResult.getOrElse((_) => throw Exception('Failed'));
      expect(retrieved.documentType, 'jobreq');
      // Note: aiResponseJson contains the structured data
    });

    test('get all documents', () async {
      // Add another document
      final dto2 = DocumentDto(
        id: 'cover_letter_1',
        content: 'Cover letter content',
        contentType: 'text/markdown',
        aiResponseJson: '{}',
        documentType: 'cover_letter',
        jobReqId: 'jobreq_1',
      );
      await datasource.saveDocument(dto2);

      final getAllResult = await datasource.getAllDocuments();
      expect(getAllResult.isRight(), true);
      final docs = getAllResult.getOrElse((_) => []);
      expect(docs.length >= 3, true); // At least the ones we saved
      expect(docs.any((d) => d.id == 'resume_1'), true);
      expect(docs.any((d) => d.id == 'jobreq_1'), true);
      expect(docs.any((d) => d.id == 'cover_letter_1'), true);
    });
  });

  group('AI Response Documents', () {
    test('save and get AI response document', () async {
      final dto = DocumentDto(
        id: 'ai_response_1',
        content: '{"response": "test"}',
        contentType: 'application/json',
        aiResponseJson: '',
        documentType: 'ai_response',
        jobReqId: 'jobreq_1',
      );

      // Save
      final saveResult = await datasource.saveAiResponseDocument(dto);
      expect(saveResult.isRight(), true);

      // Get all AI responses
      final getAllResult = await datasource.getAllAiResponseDocuments();
      expect(getAllResult.isRight(), true);
      final responses = getAllResult.getOrElse((_) => []);
      expect(responses.isNotEmpty, true);
      expect(responses.any((r) => r.id == 'ai_response_1'), true);
    });
  });
}
