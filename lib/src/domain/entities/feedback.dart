import 'package:equatable/equatable.dart';

import 'doc.dart';

/// Represents feedback document with its content.
class Feedback extends Doc with EquatableMixin {
  Feedback({required super.content, super.createdAt, super.updatedAt});

  @override
  Feedback copyWith({String? content}) {
    return Feedback(
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object> get props => [content];
}
