import 'package:equatable/equatable.dart';

import 'ai_model.dart';

/// Represents an AI provider configuration.
class AiProvider with EquatableMixin {
  /// The provider's name.
  final String name;

  /// The base URL of the provider's API.
  final String url;

  /// The API key used to authenticate with the provider.
  final String key;

  /// The models offered by this provider.
  final List<AiModel> models;

  /// The default model, if any, for this provider.
  final AiModel? defaultModel;

  /// Additional provider-specific settings.
  final Map<String, dynamic> settings;

  /// Whether this provider is the default provider.
  final bool isDefault;

  /// Creates an [AiProvider].
  const AiProvider({
    required this.name,
    required this.url,
    required this.key,
    required this.models,
    this.defaultModel,
    required this.settings,
    this.isDefault = false,
  });

  /// Returns a copy of this provider with the given fields replaced.
  AiProvider copyWith({
    String? name,
    String? url,
    String? key,
    List<AiModel>? models,
    AiModel? defaultModel,
    Map<String, dynamic>? settings,
    bool? isDefault,
  }) {
    return AiProvider(
      name: name ?? this.name,
      url: url ?? this.url,
      key: key ?? this.key,
      models: models ?? this.models,
      defaultModel: defaultModel ?? this.defaultModel,
      settings: settings ?? this.settings,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  List<Object> get props => [
    name,
    url,
    key,
    models,
    defaultModel ?? '',
    settings,
    isDefault,
  ];
}
