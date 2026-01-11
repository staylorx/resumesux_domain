/// DTO for persisting Application data to Sembast.
class ApplicationDto {
  final String id;
  final String applicantId;
  final String jobReqId;
  final DateTime createdAt;
  final DateTime updatedAt;

  ApplicationDto({
    required this.id,
    required this.applicantId,
    required this.jobReqId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Converts to a map for Sembast storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'applicantId': applicantId,
      'jobReqId': jobReqId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Creates from a map retrieved from Sembast.
  factory ApplicationDto.fromMap(Map<String, dynamic> map) {
    return ApplicationDto(
      id: map['id'] as String,
      applicantId: map['applicantId'] as String,
      jobReqId: map['jobReqId'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
