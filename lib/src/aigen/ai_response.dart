import 'package:equatable/equatable.dart';

import '../docs/doc.dart';

/// Represents an AI response document with its content.
/// AI responses are typically in JSON or Markdown format.
class AiResponse extends Doc with EquatableMixin {
  AiResponse({
    required super.content,
    super.contentType = 'application/json',
    super.createdAt,
    super.updatedAt,
  });

  @override
  AiResponse copyWith({String? content, String? contentType}) {
    return AiResponse(
      content: content ?? this.content,
      contentType: contentType ?? this.contentType,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object> get props => [content, contentType];
}
