import 'package:equatable/equatable.dart';

import '../value_objects/ai_model.dart';

/// Represents an AI provider configuration.
class AiProvider with EquatableMixin {
  final String id;
  final String url;
  final String key;
  final List<AiModel> models;
  final AiModel? defaultModel;
  final Map<String, dynamic> settings;
  final bool isDefault;

  const AiProvider({
    required this.id,
    required this.url,
    required this.key,
    required this.models,
    this.defaultModel,
    required this.settings,
    this.isDefault = false,
  });

  AiProvider copyWith({
    String? id,
    String? url,
    String? key,
    List<AiModel>? models,
    AiModel? defaultModel,
    Map<String, dynamic>? settings,
    bool? isDefault,
  }) {
    return AiProvider(
      id: id ?? this.id,
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
    id,
    url,
    key,
    models,
    defaultModel ?? '',
    settings,
    isDefault,
  ];
}
