// ignore_for_file: avoid_print

import 'package:resumesux_domain/src/domain/domain.dart';

void main() {
  // This example demonstrates creating configuration and applicant data
  // using resumesux_domain entities.

  print('Creating configuration...');

  // Create AI providers
  final lmStudioProvider = AiProvider(
    name: 'lmstudio',
    url: 'http://127.0.0.1:1234/v1',
    key: 'dummy-key',
    models: [
      AiModel(
        name: 'qwen2.5-7b-instruct',
        isDefault: true,
        settings: {'temperature': 0.8},
      ),
      AiModel(name: 'llama-2-7b-chat', settings: {'temperature': 0.7}),
    ],
    defaultModel: AiModel(
      name: 'qwen2.5-7b-instruct',
      isDefault: true,
      settings: {'temperature': 0.8},
    ),
    settings: {'max_tokens': 4000, 'temperature': 0.8},
    isDefault: true,
  );

  final ollamaProvider = AiProvider(
    name: 'ollama',
    url: 'http://127.0.0.1:11434/v1',
    key: 'dummy-key',
    models: [
      AiModel(name: 'llama2', isDefault: true, settings: {'temperature': 0.8}),
    ],
    defaultModel: AiModel(
      name: 'llama2',
      isDefault: true,
      settings: {'temperature': 0.8},
    ),
    settings: {'max_tokens': 4000},
  );

  // Create applicant
  final applicant = Applicant(
    name: 'Jane Smith',
    preferredName: 'Jane',
    email: 'jane.smith@example.com',
    address: Address(
      street1: '456 Oak Avenue',
      street2: 'Apt 2B',
      city: 'Springfield',
      state: 'IL',
      zip: '62701',
    ),
    phone: '(555) 987-6543',
    linkedin: 'https://linkedin.com/in/janesmith',
    github: 'https://github.com/janesmith',
    portfolio: 'https://janesmith.dev',
  );

  // Create configuration
  final config = Config(
    outputDir: './output',
    includeCover: true,
    includeFeedback: true,
    providers: [lmStudioProvider, ollamaProvider],
    customPrompt:
        'Generate professional content tailored to the job requirements.',
    appendPrompt: true,
    applicant: applicant,
    digestPath: '',
  );

  print('Configuration created successfully!');
  print('Output Directory: ${config.outputDir}');
  print('Include Cover Letter: ${config.includeCover}');
  print('Include Feedback: ${config.includeFeedback}');
  print('Custom Prompt: ${config.customPrompt}');
  print('Append Prompt: ${config.appendPrompt}');

  print('\nAI Providers:');
  for (final provider in config.providers) {
    print('- ${provider.name} (Default: ${provider.isDefault})');
    print('  URL: ${provider.url}');
    print('  Models: ${provider.models.map((m) => m.name).join(', ')}');
    print('  Default Model: ${provider.defaultModel?.name}');
  }

  print('\nApplicant Details:');
  print('Name: ${config.applicant.name} (${config.applicant.preferredName})');
  print('Email: ${config.applicant.email}');
  print('Phone: ${config.applicant.phone}');
  print('LinkedIn: ${config.applicant.linkedin}');
  print('GitHub: ${config.applicant.github}');
  if (config.applicant.portfolio != null) {
    print('Portfolio: ${config.applicant.portfolio}');
  }
  if (config.applicant.address != null) {
    print('Address:');
    if (config.applicant.address!.street1 != null) {
      print('  ${config.applicant.address!.street1}');
    }
    if (config.applicant.address!.street2 != null) {
      print('  ${config.applicant.address!.street2}');
    }
    if (config.applicant.address!.city != null &&
        config.applicant.address!.state != null &&
        config.applicant.address!.zip != null) {
      print(
        '  ${config.applicant.address!.city}, ${config.applicant.address!.state} ${config.applicant.address!.zip}',
      );
    }
  }

  print('\nConfiguration and applicant setup example completed.');
}
