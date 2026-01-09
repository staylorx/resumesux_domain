/// Abstract base class for documents.
abstract class Doc {
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  Doc({required this.content, DateTime? createdAt, DateTime? updatedAt})
    : createdAt = createdAt ?? DateTime.now(),
      updatedAt = updatedAt ?? DateTime.now();

  Doc copyWith({String? content});
}
