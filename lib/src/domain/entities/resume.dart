import 'package:equatable/equatable.dart';

import 'doc.dart';

/// Represents a resume document with its content.
class Resume extends Doc with EquatableMixin {
  Resume({required super.content, super.createdAt, super.updatedAt});

  @override
  Resume copyWith({String? content}) {
    return Resume(
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object> get props => [content];
}
