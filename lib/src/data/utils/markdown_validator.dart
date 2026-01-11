import 'dart:io';
import 'package:markdown/markdown.dart';
import 'package:resumesux_domain/src/domain/failure.dart';

// TODO: this has too much "io" in it for domain layer, consider moving to data layer
// should use some kind of file adapter

/// Validates that all Markdown files in the directory are valid Markdown.
Future<void> validateMarkdownFiles({
  required String directory,
  required String fileExtension,
}) async {
  final dir = Directory(directory);
  if (!dir.existsSync()) {
    throw ParsingFailure(message: 'Directory $directory does not exist.');
  }

  final files = dir
      .listSync()
      .where((file) => file.path.endsWith(fileExtension))
      .toList();

  for (final file in files) {
    final content = File(file.path).readAsStringSync();

    // Validate Markdown parsing
    try {
      markdownToHtml(content);
    } catch (e) {
      throw ParsingFailure(
        message: 'File ${file.path} is not valid Markdown: $e',
      );
    }
  }
}
