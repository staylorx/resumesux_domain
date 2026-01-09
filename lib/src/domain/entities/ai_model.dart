import 'package:equatable/equatable.dart';

import 'ai_provider.dart';

/// Represents an AI model configuration.
class AiModel with EquatableMixin {
  final String name;
  final AiProvider provider;
  final bool isDefault;
  final Map<String, dynamic> settings;

  const AiModel({
    required this.name,
    required this.provider,
    this.isDefault = false,
    this.settings = const {},
  });

  AiModel copyWith({
    String? name,
    AiProvider? provider,
    bool? isDefault,
    Map<String, dynamic>? settings,
  }) {
    return AiModel(
      name: name ?? this.name,
      provider: provider ?? this.provider,
      isDefault: isDefault ?? this.isDefault,
      settings: settings ?? this.settings,
    );
  }

  @override
  List<Object> get props => [name, provider, isDefault, settings];
}
