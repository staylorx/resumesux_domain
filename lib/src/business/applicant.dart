import 'package:equatable/equatable.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Represents an applicant with personal and professional information.
class Applicant with EquatableMixin {
  /// The applicant's full name.
  final String name;

  /// An optional preferred name the applicant goes by.
  final String? preferredName;

  /// The applicant's email address.
  final String email;

  /// The applicant's postal address, or null if not provided.
  final Address? address;

  /// The applicant's phone number.
  final String? phone;

  /// URL of the applicant's LinkedIn profile.
  final String? linkedin;

  /// URL of the applicant's GitHub profile.
  final String? github;

  /// URL of the applicant's portfolio or personal website.
  final String? portfolio;

  /// Work, volunteer, or internship experience associated with the applicant.
  final List<Gig> gigs;

  /// Assets (education, licenses, certifications, etc.) associated with the applicant.
  final List<Asset> assets;

  /// Constructs an [Applicant] with the required personal and professional details.
  const Applicant({
    required this.name,
    this.preferredName,
    required this.email,
    this.address,
    this.phone,
    this.linkedin,
    this.github,
    this.portfolio,
    this.gigs = const [],
    this.assets = const [],
  });

  /// Returns a copy of this [Applicant] with the given fields replaced.
  Applicant copyWith({
    String? name,
    String? preferredName,
    String? email,
    Address? address,
    String? phone,
    String? linkedin,
    String? github,
    String? portfolio,
    List<Gig>? gigs,
    List<Asset>? assets,
  }) {
    return Applicant(
      name: name ?? this.name,
      preferredName: preferredName ?? this.preferredName,
      email: email ?? this.email,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      linkedin: linkedin ?? this.linkedin,
      github: github ?? this.github,
      portfolio: portfolio ?? this.portfolio,
      gigs: gigs ?? this.gigs,
      assets: assets ?? this.assets,
    );
  }

  @override
  List<Object?> get props => [name, email];
}
