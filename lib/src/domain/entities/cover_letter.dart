import 'package:equatable/equatable.dart';
import 'doc.dart';

/// Represents a cover letter document with its content.
class CoverLetter extends Doc with EquatableMixin {
  CoverLetter({required super.content, super.createdAt, super.updatedAt});

  @override
  CoverLetter copyWith({String? content}) {
    return CoverLetter(
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object> get props => [content];
}
