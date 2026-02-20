/// DTO for persisting Asset data to Sembast.
class AssetDto {
  final String id;
  final List<String> tagNames;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  AssetDto({
    required this.id,
    required this.tagNames,
    required this.content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Converts to a map for Sembast storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tagNames': tagNames,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Creates from a map retrieved from Sembast.
  factory AssetDto.fromMap(Map<String, dynamic> map) {
    return AssetDto(
      id: map['id'] as String,
      tagNames: (map['tagNames'] as List<dynamic>).cast<String>(),
      content: map['content'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
