/// Abstract base class for documents.
abstract class Document {
  final String content;
  final String contentType;
  final DateTime createdAt;
  final DateTime updatedAt;

  Document({
    required this.content,
    required this.contentType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Document copyWith({String? content, String? contentType});
}
