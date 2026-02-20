/// DTO for persisting document data with AI response to Sembast.
class DocumentDto {
  final String id;
  final String content;
  final String contentType;
  final String aiResponseJson;
  final DateTime createdAt;
  final String? jobReqId;
  final String
  documentType; // 'resume', 'cover_letter', 'feedback', 'ai_response'

  DocumentDto({
    required this.id,
    required this.content,
    required this.contentType,
    required this.aiResponseJson,
    required this.documentType,
    this.jobReqId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Converts to a map for Sembast storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'contentType': contentType,
      'aiResponseJson': aiResponseJson,
      'createdAt': createdAt.toIso8601String(),
      'jobReqId': jobReqId,
      'documentType': documentType,
    };
  }

  /// Creates from a map retrieved from Sembast.
  factory DocumentDto.fromMap(Map<String, dynamic> map) {
    return DocumentDto(
      id: map['id'] as String,
      content: map['content'] as String,
      contentType: map['contentType'] as String,
      aiResponseJson: map['aiResponseJson'] as String,
      documentType: map['documentType'] as String,
      jobReqId: map['jobReqId'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
