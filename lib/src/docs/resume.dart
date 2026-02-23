import 'package:equatable/equatable.dart';

import 'doc.dart';

/// Represents a resume document with its content.
class Resume extends Document with EquatableMixin {
  Resume({
    required super.content,
    super.contentType = 'text/markdown',
    super.createdAt,
    super.updatedAt,
  });

  @override
  Resume copyWith({String? content, String? contentType}) {
    return Resume(
      content: content ?? this.content,
      contentType: contentType ?? this.contentType,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object> get props => [content, contentType];
}
