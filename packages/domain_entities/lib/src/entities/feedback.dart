import 'package:equatable/equatable.dart';

import 'doc.dart';

/// Represents feedback document with its content.
class Feedback extends Doc with EquatableMixin {
  Feedback({
    required super.content,
    super.contentType = 'text/markdown',
    super.createdAt,
    super.updatedAt,
  });

  @override
  Feedback copyWith({String? content, String? contentType}) {
    return Feedback(
      content: content ?? this.content,
      contentType: contentType ?? this.contentType,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object> get props => [content, contentType];
}
