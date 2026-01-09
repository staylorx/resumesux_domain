import 'package:equatable/equatable.dart';

import 'doc.dart';

/// Represents feedback document with its content.
class Feedback extends Doc with EquatableMixin {
  final String content;

  Feedback({required this.content});

  Feedback copyWith({String? content}) {
    return Feedback(content: content ?? this.content);
  }

  @override
  List<Object> get props => [content];
}
