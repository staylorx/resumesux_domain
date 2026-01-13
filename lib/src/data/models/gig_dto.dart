/// DTO for persisting Gig data to Sembast.
class GigDto {
  final String id;
  final String? concern;
  final String? location;
  final String title;
  final String? dates;
  final List<String>? achievements;
  final DateTime createdAt;
  final DateTime updatedAt;

  GigDto({
    required this.id,
    this.concern,
    this.location,
    required this.title,
    this.dates,
    this.achievements,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Converts to a map for Sembast storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'concern': concern,
      'location': location,
      'title': title,
      'dates': dates,
      'achievements': achievements,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Creates from a map retrieved from Sembast.
  factory GigDto.fromMap(Map<String, dynamic> map) {
    return GigDto(
      id: map['id'] as String,
      concern: map['concern'] as String?,
      location: map['location'] as String?,
      title: map['title'] as String,
      dates: map['dates'] as String?,
      achievements: (map['achievements'] as List<dynamic>?)?.cast<String>(),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
