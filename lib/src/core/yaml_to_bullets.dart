import 'dart:io';
import 'package:yaml/yaml.dart';

/// Converts YAML front-matter in Markdown files to bullet points.
///
/// Scans the specified directory for files with the given extension,
/// extracts YAML front-matter, and replaces it with bullet points based on field mappings.
Future<void> convertYamlToBullets({
  required String directory,
  required String fileExtension,
  required Map<String, String> fieldMappings,
}) async {
  final dir = Directory(directory);
  if (!dir.existsSync()) {
    stdout.writeln('Directory $directory does not exist.');
    return;
  }

  final files = dir
      .listSync()
      .where((file) => file.path.endsWith(fileExtension))
      .toList();
  int updatedCount = 0;

  for (final file in files) {
    final content = File(file.path).readAsStringSync();
    final lines = content.split('\n');

    // Find YAML front-matter
    if (lines.length < 3 || lines[0] != '---') {
      continue; // No YAML front-matter
    }

    int endIndex = -1;
    for (int i = 1; i < lines.length; i++) {
      if (lines[i] == '---') {
        endIndex = i;
        break;
      }
    }

    if (endIndex == -1) {
      continue; // No closing ---
    }

    // Extract YAML block
    final yamlBlock = lines.sublist(1, endIndex).join('\n');
    final yamlMap = loadYaml(yamlBlock) as YamlMap;

    // Create bullet points
    final bullets = <String>[];
    for (final entry in fieldMappings.entries) {
      final value = yamlMap[entry.key]?.toString() ?? '';
      if (value.isNotEmpty) {
        bullets.add('- ${entry.value}: $value');
      }
    }

    final newContent =
        '${bullets.join('\n')}\n\n${lines.sublist(endIndex + 1).join('\n')}';

    // Write back
    File(file.path).writeAsStringSync(newContent);
    updatedCount++;
  }

  stdout.writeln('Updated $updatedCount files.');
}
