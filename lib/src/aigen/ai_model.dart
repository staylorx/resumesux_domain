import 'package:equatable/equatable.dart';

import 'ai_provider.dart';

/// Represents an AI model configuration.
class AiModel with EquatableMixin {
  /// The model's name.
  final String name;

  /// Whether this model is the default for its provider.
  final bool isDefault;

  /// Additional provider-specific settings for the model.
  final Map<String, dynamic> settings;

  /// Creates an [AiModel].
  const AiModel({
    required this.name,
    this.isDefault = false,
    this.settings = const {},
  });

  /// Returns a copy of this model with the given fields replaced.
  AiModel copyWith({
    String? name,
    AiProvider? provider,
    bool? isDefault,
    Map<String, dynamic>? settings,
  }) {
    return AiModel(
      name: name ?? this.name,
      isDefault: isDefault ?? this.isDefault,
      settings: settings ?? this.settings,
    );
  }

  @override
  List<Object> get props => [name];
}
