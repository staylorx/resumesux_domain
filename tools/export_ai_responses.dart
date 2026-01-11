// ignore_for_file: avoid_print

import 'dart:io';
import 'package:args/args.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('db-path', abbr: 'd', help: 'Path to the Sembast database file')
    ..addOption(
      'output-dir',
      abbr: 'o',
      help: 'Output directory for exported JSON files',
      defaultsTo: 'ai_responses_export',
    )
    ..addOption(
      'jobReqId',
      abbr: 'j',
      help: 'Export only for specific jobReqId',
    )
    ..addFlag(
      'all',
      abbr: 'a',
      help: 'Export all AI responses',
      defaultsTo: true,
    )
    ..addFlag('help', abbr: 'h', help: 'Show help');

  final results = parser.parse(arguments);

  if (results['help'] as bool) {
    print('Export AI responses from Sembast database to JSON files.');
    print('');
    print('Usage: dart run tools/export_ai_responses.dart [options]');
    print('');
    print(parser.usage);
    return;
  }

  final dbPath = results['db-path'] as String?;
  if (dbPath == null) {
    print('Error: --db-path is required');
    exit(1);
  }

  final outputDir = results['output-dir'] as String;
  final jobReqId = results['jobReqId'] as String?;
  final exportAll = results['all'] as bool;

  // Initialize datasource
  final dbService = SembastDatabaseService(
    dbPath: dbPath,
    dbName: 'applications.db',
  );
  final applicationDatasource = ApplicationDatasource(dbService: dbService);

  // Get all AI response documents
  final documentsResult = await applicationDatasource
      .getAllAiResponseDocuments();
  if (documentsResult.isLeft()) {
    print(
      'Error: Failed to get documents: ${documentsResult.getLeft().toNullable()?.message}',
    );
    exit(1);
  }

  final documents = documentsResult.getOrElse((_) => []);

  // Filter documents
  final filteredDocuments = documents.where((doc) {
    if (jobReqId != null) {
      return doc.jobReqId == jobReqId;
    }
    if (!exportAll) {
      return false;
    }
    return true;
  }).toList();

  if (filteredDocuments.isEmpty) {
    print('No AI responses found to export.');
    return;
  }

  // Create output directory
  final dir = Directory(outputDir);
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  // Group by jobReqId
  final grouped = <String, List<DocumentDto>>{};
  for (final doc in filteredDocuments) {
    final key = doc.jobReqId ?? 'unknown';
    grouped.putIfAbsent(key, () => []).add(doc);
  }

  // Export each group
  for (final entry in grouped.entries) {
    final jobReqId = entry.key;
    final docs = entry.value;

    final jobReqDir = Directory('$outputDir/$jobReqId');
    if (!jobReqDir.existsSync()) {
      jobReqDir.createSync();
    }

    for (final doc in docs) {
      final fileName = '${doc.documentType}.json';
      final file = File('${jobReqDir.path}/$fileName');
      await file.writeAsString(doc.aiResponseJson);
      print(
        'Exported ${doc.documentType} for jobReqId $jobReqId to ${file.path}',
      );
    }
  }

  print('Export completed. ${filteredDocuments.length} AI responses exported.');
}
