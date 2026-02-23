import 'package:equatable/equatable.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Represents an applicant with personal and professional information.
class Applicant with EquatableMixin {
  final String name;
  final String? preferredName;
  final String email;
  final Address? address;
  final String? phone;
  final String? linkedin;
  final String? github;
  final String? portfolio;
  final List<Gig> gigs;
  final List<Asset> assets;

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
