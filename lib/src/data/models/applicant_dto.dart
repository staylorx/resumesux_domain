/// DTO for persisting Applicant data to Sembast.
class ApplicantDto {
  final String id;
  final String name;
  final String? preferredName;
  final String email;
  final Map<String, dynamic>? address;
  final String? phone;
  final String? linkedin;
  final String? github;
  final String? portfolio;
  final List<String> gigIds;
  final List<String> assetIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  ApplicantDto({
    required this.id,
    required this.name,
    this.preferredName,
    required this.email,
    this.address,
    this.phone,
    this.linkedin,
    this.github,
    this.portfolio,
    this.gigIds = const [],
    this.assetIds = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Converts to a map for Sembast storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'preferredName': preferredName,
      'email': email,
      'address': address,
      'phone': phone,
      'linkedin': linkedin,
      'github': github,
      'portfolio': portfolio,
      'gigIds': gigIds,
      'assetIds': assetIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Creates from a map retrieved from Sembast.
  factory ApplicantDto.fromMap(Map<String, dynamic> map) {
    return ApplicantDto(
      id: map['id'] as String,
      name: map['name'] as String,
      preferredName: map['preferredName'] as String?,
      email: map['email'] as String,
      address: map['address'] as Map<String, dynamic>?,
      phone: map['phone'] as String?,
      linkedin: map['linkedin'] as String?,
      github: map['github'] as String?,
      portfolio: map['portfolio'] as String?,
      gigIds: (map['gigIds'] as List<dynamic>?)?.cast<String>() ?? [],
      assetIds: (map['assetIds'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
