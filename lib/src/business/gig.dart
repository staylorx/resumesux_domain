import 'package:equatable/equatable.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Represents a professional gig or job experience.
/// It can also be a volunteer position or internship.
class Gig with EquatableMixin {
  /// The concern (company or organization) where the gig took place.
  final Concern? concern;

  /// The location of the gig.
  final String? location;

  /// The title or role of the gig.
  final String title;

  /// A date range string describing when the gig occurred.
  final String? dates;

  /// Key achievements or accomplishments during the gig.
  final List<String>? achievements;

  /// Constructs a [Gig] with the given details.
  const Gig({
    this.concern,
    this.location,
    required this.title,
    this.dates,
    this.achievements,
  });

  /// Returns a copy of this [Gig] with the given fields replaced.
  Gig copyWith({
    Concern? concern,
    String? location,
    String? title,
    String? dates,
    List<String>? achievements,
  }) {
    return Gig(
      concern: concern ?? this.concern,
      location: location ?? this.location,
      title: title ?? this.title,
      dates: dates ?? this.dates,
      achievements: achievements ?? this.achievements,
    );
  }

  @override
  List<Object> get props => [title];
}
