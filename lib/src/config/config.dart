import 'package:equatable/equatable.dart';
import '../business/applicant.dart';
import '../aigen/ai_provider.dart';
import '../enums/folder_field.dart';

/// Represents the application configuration including output settings and AI providers.
class Config with EquatableMixin {
  /// Directory where generated application output is written.
  final String outputDir;

  /// Whether to include a cover letter in the generated application.
  final bool includeCover;

  /// Whether to include feedback in the generated application.
  final bool includeFeedback;

  /// List of AI providers configured for generation.
  final List<AiProvider> providers;

  /// Optional custom prompt for AI generation.
  final String? customPrompt;

  /// Whether the custom prompt should be appended to default prompts.
  final bool appendPrompt;

  /// The applicant the configuration applies to.
  final Applicant applicant;

  /// Path to the digest directory.
  final String digestPath;

  /// Order of fields used to create the output folder structure.
  final List<FolderField>? folderOrder;

  /// Constructs a [Config] with the given settings.
  const Config({
    required this.outputDir,
    required this.includeCover,
    required this.includeFeedback,
    required this.providers,
    this.customPrompt,
    required this.appendPrompt,
    required this.applicant,
    required this.digestPath,
    this.folderOrder,
  });

  /// Returns a copy of this [Config] with the given fields replaced.
  Config copyWith({
    String? outputDir,
    bool? includeCover,
    bool? includeFeedback,
    List<AiProvider>? providers,
    String? customPrompt,
    bool? appendPrompt,
    Applicant? applicant,
    String? digestPath,
    List<FolderField>? folderOrder,
  }) {
    return Config(
      outputDir: outputDir ?? this.outputDir,
      includeCover: includeCover ?? this.includeCover,
      includeFeedback: includeFeedback ?? this.includeFeedback,
      providers: providers ?? this.providers,
      customPrompt: customPrompt ?? this.customPrompt,
      appendPrompt: appendPrompt ?? this.appendPrompt,
      applicant: applicant ?? this.applicant,
      digestPath: digestPath ?? this.digestPath,
      folderOrder: folderOrder ?? this.folderOrder,
    );
  }

  @override
  List<Object?> get props => [
    outputDir,
    includeCover,
    includeFeedback,
    providers,
    customPrompt,
    appendPrompt,
    applicant,
    digestPath,
    folderOrder,
  ];
}
