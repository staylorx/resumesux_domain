/// Abstract base class for documents.
abstract class Document {
  /// The raw content of the document.
  final String content;

  /// The MIME type of the document content.
  final String contentType;

  /// When the document was created.
  final DateTime createdAt;

  /// When the document was last updated.
  final DateTime updatedAt;

  /// Constructs a [Document]; timestamps default to the current time.
  Document({
    required this.content,
    required this.contentType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Returns a copy of this [Document] with the given fields replaced.
  Document copyWith({String? content, String? contentType});
}
