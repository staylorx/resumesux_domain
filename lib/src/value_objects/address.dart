import 'package:equatable/equatable.dart';

/// Represents a physical address with optional street, city, state, and zip components.
class Address with EquatableMixin {
  /// The first street address line.
  final String? street1;

  /// The second street address line.
  final String? street2;

  /// The city.
  final String? city;

  /// The state or region.
  final String? state;

  /// The postal / zip code.
  final String? zip;

  /// Creates an [Address] with the given components.
  const Address({this.street1, this.street2, this.city, this.state, this.zip});

  /// Returns a copy of this address with the given fields replaced.
  Address copyWith({
    String? street1,
    String? street2,
    String? city,
    String? state,
    String? zip,
  }) {
    return Address(
      street1: street1 ?? this.street1,
      street2: street2 ?? this.street2,
      city: city ?? this.city,
      state: state ?? this.state,
      zip: zip ?? this.zip,
    );
  }

  @override
  List<Object?> get props => [street1, street2, city, state, zip];
}
