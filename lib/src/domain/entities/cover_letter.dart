import 'package:equatable/equatable.dart';

import 'doc.dart';

/// Represents a cover letter document with its content.
class CoverLetter extends Doc with EquatableMixin {
  final String content;

  CoverLetter({required this.content});

  CoverLetter copyWith({String? content}) {
    return CoverLetter(content: content ?? this.content);
  }

  @override
  List<Object> get props => [content];
}
