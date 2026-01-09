import 'package:equatable/equatable.dart';

import 'doc.dart';

/// Represents a resume document with its content.
class Resume extends Doc with EquatableMixin {
  final String content;

  Resume({required this.content});

  Resume copyWith({String? content}) {
    return Resume(content: content ?? this.content);
  }

  @override
  List<Object> get props => [content];
}
