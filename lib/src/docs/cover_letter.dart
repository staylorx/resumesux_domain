import 'package:equatable/equatable.dart';
import 'doc.dart';

/// Represents a cover letter document with its content.
class CoverLetter extends Document with EquatableMixin {
  CoverLetter({
    required super.content,
    super.contentType = 'text/markdown',
    super.createdAt,
    super.updatedAt,
  });

  @override
  CoverLetter copyWith({String? content, String? contentType}) {
    return CoverLetter(
      content: content ?? this.content,
      contentType: contentType ?? this.contentType,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object> get props => [content, contentType];
}
