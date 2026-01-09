import 'package:equatable/equatable.dart';
import 'applicant.dart';
import 'ai_provider.dart';

/// Represents the application configuration including output settings and AI providers.
class Config with EquatableMixin {
  final String outputDir;
  // Whether to include cover letter in the generated application
  final bool includeCover;
  // Whether to include feedback in the generated application
  final bool includeFeedback;
  // List of AI providers configured
  final List<AiProvider> providers;
  // Optional custom prompt for AI generation
  final String? customPrompt;
  // Indicates if the custom prompt should be appended to default prompts
  final bool appendPrompt;
  // Applicant information
  final Applicant applicant;
  // Path to the digest directory
  final String digestPath;

  const Config({
    required this.outputDir,
    required this.includeCover,
    required this.includeFeedback,
    required this.providers,
    this.customPrompt,
    required this.appendPrompt,
    required this.applicant,
    required this.digestPath,
  });

  Config copyWith({
    String? outputDir,
    bool? includeCover,
    bool? includeFeedback,
    List<AiProvider>? providers,
    String? customPrompt,
    bool? appendPrompt,
    Applicant? applicant,
    String? digestPath,
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
  ];
}
