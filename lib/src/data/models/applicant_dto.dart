import '../../domain/entities/applicant.dart';
import '../../domain/value_objects/address.dart';

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

  ApplicantDto copyWith({
    String? id,
    String? name,
    String? preferredName,
    String? email,
    Map<String, dynamic>? address,
    String? phone,
    String? linkedin,
    String? github,
    String? portfolio,
    List<String>? gigIds,
    List<String>? assetIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ApplicantDto(
      id: id ?? this.id,
      name: name ?? this.name,
      preferredName: preferredName ?? this.preferredName,
      email: email ?? this.email,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      linkedin: linkedin ?? this.linkedin,
      github: github ?? this.github,
      portfolio: portfolio ?? this.portfolio,
      gigIds: gigIds ?? this.gigIds,
      assetIds: assetIds ?? this.assetIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

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

  /// Creates from domain entity.
  factory ApplicantDto.fromDomain(Applicant applicant, String id) {
    return ApplicantDto(
      id: id,
      name: applicant.name,
      preferredName: applicant.preferredName,
      email: applicant.email,
      address: applicant.address != null
          ? {
              'street1': applicant.address!.street1,
              'street2': applicant.address!.street2,
              'city': applicant.address!.city,
              'state': applicant.address!.state,
              'zip': applicant.address!.zip,
            }
          : null,
      phone: applicant.phone,
      linkedin: applicant.linkedin,
      github: applicant.github,
      portfolio: applicant.portfolio,
      gigIds: [], // Will be set by repository
      assetIds: [], // Will be set by repository
    );
  }

  /// Converts to domain entity.
  /// Note: This creates an Applicant with empty gigs and assets.
  /// The repository should load the actual gigs and assets separately.
  Applicant toDomain() {
    return Applicant(
      name: name,
      preferredName: preferredName,
      email: email,
      address: address != null
          ? Address(
              street1: address!['street1'] as String?,
              street2: address!['street2'] as String?,
              city: address!['city'] as String?,
              state: address!['state'] as String?,
              zip: address!['zip'] as String?,
            )
          : null,
      phone: phone,
      linkedin: linkedin,
      github: github,
      portfolio: portfolio,
      gigs: [],
      assets: [],
    );
  }
}
